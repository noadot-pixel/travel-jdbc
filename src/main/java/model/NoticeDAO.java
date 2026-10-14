package model;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

import util.DBUtil;

/**
 * NOTICES 테이블(관리자 공지사항)을 다루는 DAO.
 */
public class NoticeDAO {

	private static final String COLUMNS =
			"n.notice_id, n.title, n.content, n.writer, m.nickname writer_nick, "
		  + "to_char(n.reg_date, 'YYYY-MM-DD HH24:MI') reg_date ";

	private NoticeDTO toDto(ResultSet rs) throws Exception {

		NoticeDTO dto = new NoticeDTO();
		dto.setNoticeId(rs.getInt("notice_id"));
		dto.setTitle(rs.getString("title"));
		dto.setContent(rs.getString("content"));
		dto.setWriter(rs.getString("writer"));
		dto.setWriterNick(rs.getString("writer_nick"));
		dto.setRegDate(rs.getString("reg_date"));
		return dto;
	}

	//공지 상세(/notice/view) - 없는 번호면 null
	public NoticeDTO getById(int noticeId) {

		String sql = "select " + COLUMNS
				   + "from notices n join members m on n.writer = m.id "
				   + "where n.notice_id = ?";

		NoticeDTO dto = null;

		try (Connection conn = DBUtil.getInstance();
			 PreparedStatement pstmt = conn.prepareStatement(sql)) {

			pstmt.setInt(1, noticeId);

			try (ResultSet rs = pstmt.executeQuery()) {
				if (rs.next()) {
					dto = toDto(rs);
				}
			}

		} catch (Exception e) {
			System.out.println(e.getMessage());
		}

		return dto;
	}

	//관리자 화면용 전체 목록(최신순)
	public List<NoticeDTO> getList() {

		String sql = "select " + COLUMNS
				   + "from notices n join members m on n.writer = m.id "
				   + "order by n.notice_id desc";

		List<NoticeDTO> list = new ArrayList<NoticeDTO>();

		try (Connection conn = DBUtil.getInstance();
			 PreparedStatement pstmt = conn.prepareStatement(sql);
			 ResultSet rs = pstmt.executeQuery()) {

			while (rs.next()) {
				list.add(toDto(rs));
			}

		} catch (Exception e) {
			System.out.println(e.getMessage());
		}

		return list;
	}

	//알림 벨 드롭다운에 보여줄 최신 n개
	public List<NoticeDTO> getRecent(int n) {

		String sql = "select * from ( "
				   + "  select " + COLUMNS
				   + "  from notices n join members m on n.writer = m.id "
				   + "  order by n.notice_id desc "
				   + ") where rownum <= ?";

		List<NoticeDTO> list = new ArrayList<NoticeDTO>();

		try (Connection conn = DBUtil.getInstance();
			 PreparedStatement pstmt = conn.prepareStatement(sql)) {

			pstmt.setInt(1, n);

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

	//이 회원이 마지막으로 알림을 확인한 시각(lastSeen) 이후에 올라온 공지 개수
	//한 번도 확인한 적이 없으면(NULL) 전부 안 읽은 것으로 센다.
	public int countUnread(String memberId) {

		String sql = "select count(*) "
				   + "from notices n join members m on m.id = ? "
				   + "where n.reg_date > nvl(m.last_notice_seen, to_date('2000-01-01', 'YYYY-MM-DD'))";

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

	//관리자 공지 등록 - 성공하면 새 글 번호, 실패하면 0
	public int insert(String title, String content, String writer) {

		String seqSql = "select seq_notices.nextval from dual";
		String sql = "insert into notices(notice_id, title, content, writer) values(?, ?, ?, ?)";

		int noticeId = 0;

		try (Connection conn = DBUtil.getInstance();
			 PreparedStatement seqPstmt = conn.prepareStatement(seqSql);
			 PreparedStatement pstmt = conn.prepareStatement(sql)) {

			try (ResultSet rs = seqPstmt.executeQuery()) {
				if (rs.next()) {
					noticeId = rs.getInt(1);
				}
			}

			pstmt.setInt(1, noticeId);
			pstmt.setString(2, title);
			pstmt.setString(3, content);
			pstmt.setString(4, writer);

			if (pstmt.executeUpdate() == 0) {
				noticeId = 0;
			}

		} catch (Exception e) {
			System.out.println(e.getMessage());
			noticeId = 0;
		}

		return noticeId;
	}

	public int delete(int noticeId) {

		String sql = "delete from notices where notice_id = ?";

		int result = 0;

		try (Connection conn = DBUtil.getInstance();
			 PreparedStatement pstmt = conn.prepareStatement(sql)) {

			pstmt.setInt(1, noticeId);
			result = pstmt.executeUpdate();

		} catch (Exception e) {
			System.out.println(e.getMessage());
		}

		return result;
	}

	//알림 벨을 열어본 시각을 지금으로 기록한다 (공지 "읽음" 처리 - 개인별 컬럼이 아니라
	//회원 한 명당 "마지막으로 확인한 시각" 하나만 저장하는 방식이라 별도 테이블이 필요 없다)
	public void markSeen(String memberId) {

		String sql = "update members set last_notice_seen = ? where id = ?";

		try (Connection conn = DBUtil.getInstance();
			 PreparedStatement pstmt = conn.prepareStatement(sql)) {

			pstmt.setTimestamp(1, new Timestamp(System.currentTimeMillis()));
			pstmt.setString(2, memberId);
			pstmt.executeUpdate();

		} catch (Exception e) {
			System.out.println(e.getMessage());
		}
	}

}
