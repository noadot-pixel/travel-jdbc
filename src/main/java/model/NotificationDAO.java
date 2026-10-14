package model;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import util.DBUtil;

/**
 * NOTIFICATIONS 테이블(내 글에 달린 댓글/좋아요 개인 알림)을 다루는 DAO.
 */
public class NotificationDAO {

	private static final String COLUMNS =
			"nf.notif_id, nf.type, nf.bno, p.title post_title, nf.actor_id, m.nickname actor_nick, "
		  + "nf.is_read, to_char(nf.reg_date, 'YYYY-MM-DD HH24:MI') reg_date ";

	private NotificationDTO toDto(ResultSet rs) throws Exception {

		NotificationDTO dto = new NotificationDTO();
		dto.setNotifId(rs.getInt("notif_id"));
		dto.setType(rs.getString("type"));
		dto.setBno(rs.getInt("bno"));
		dto.setPostTitle(rs.getString("post_title"));
		dto.setActorId(rs.getString("actor_id"));
		dto.setActorNick(rs.getString("actor_nick"));
		dto.setRead("Y".equals(rs.getString("is_read")));
		dto.setRegDate(rs.getString("reg_date"));
		return dto;
	}

	//댓글/좋아요 알림 적재 - 자기 글에 자기가 댓글을 달거나 좋아요를 누른 경우는 알릴 필요가 없어서 뺀다.
	public void insert(String targetMemberId, String type, int bno, String actorId) {

		if (targetMemberId.equals(actorId)) {
			return;
		}

		String seqSql = "select seq_notifications.nextval from dual";
		String sql = "insert into notifications(notif_id, member_id, type, bno, actor_id) values(?, ?, ?, ?, ?)";

		try (Connection conn = DBUtil.getInstance();
			 PreparedStatement seqPstmt = conn.prepareStatement(seqSql);
			 PreparedStatement pstmt = conn.prepareStatement(sql)) {

			int notifId = 0;
			try (ResultSet rs = seqPstmt.executeQuery()) {
				if (rs.next()) {
					notifId = rs.getInt(1);
				}
			}

			pstmt.setInt(1, notifId);
			pstmt.setString(2, targetMemberId);
			pstmt.setString(3, type);
			pstmt.setInt(4, bno);
			pstmt.setString(5, actorId);
			pstmt.executeUpdate();

		} catch (Exception e) {
			System.out.println(e.getMessage());
		}
	}

	//알림 벨 드롭다운에 보여줄 이 회원의 최신 n개(읽음 여부 상관없이)
	public List<NotificationDTO> getRecent(String memberId, int n) {

		String sql = "select * from ( "
				   + "  select " + COLUMNS
				   + "  from notifications nf "
				   + "  join posts p on nf.bno = p.bno "
				   + "  join members m on nf.actor_id = m.id "
				   + "  where nf.member_id = ? "
				   + "  order by nf.notif_id desc "
				   + ") where rownum <= ?";

		List<NotificationDTO> list = new ArrayList<NotificationDTO>();

		try (Connection conn = DBUtil.getInstance();
			 PreparedStatement pstmt = conn.prepareStatement(sql)) {

			pstmt.setString(1, memberId);
			pstmt.setInt(2, n);

			try (ResultSet rs = pstmt.executeQuery()) {
				while (rs.next()) {
					list.add(toDto(rs));
				}
			}

		} catch (Exception e) {
			System.out.println(e.getMessage());
		}

		return list;
	}

	public int countUnread(String memberId) {

		String sql = "select count(*) from notifications where member_id = ? and is_read = 'N'";

		int count = 0;

		try (Connection conn = DBUtil.getInstance();
			 PreparedStatement pstmt = conn.prepareStatement(sql)) {

			pstmt.setString(1, memberId);

			try (ResultSet rs = pstmt.executeQuery()) {
				if (rs.next()) {
					count = rs.getInt(1);
				}
			}

		} catch (Exception e) {
			System.out.println(e.getMessage());
		}

		return count;
	}

	//알림 벨을 열어본 시점에 이 회원의 안 읽은 알림을 전부 읽음 처리한다.
	public void markAllRead(String memberId) {

		String sql = "update notifications set is_read = 'Y' where member_id = ? and is_read = 'N'";

		try (Connection conn = DBUtil.getInstance();
			 PreparedStatement pstmt = conn.prepareStatement(sql)) {

			pstmt.setString(1, memberId);
			pstmt.executeUpdate();

		} catch (Exception e) {
			System.out.println(e.getMessage());
		}
	}

}
