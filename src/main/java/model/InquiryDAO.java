package model;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import util.DBUtil;

/**
 * INQUIRIES 테이블(문의하기 게시판)을 다루는 DAO. 로그인한 회원이면 남길 수 있다.
 * 답변/대화는 댓글(INQUIRY_COMMENTS, InquiryCommentDAO)로 처리한다.
 * 비공개로 남긴 글은 작성자 본인과 관리자만 볼 수 있다.
 */
public class InquiryDAO {

	private static final String COLUMNS =
			"i.inquiry_id, i.title, i.content, i.writer, m.nickname writer_nick, "
		  + "to_char(i.reg_date, 'YYYY-MM-DD HH24:MI') reg_date, i.is_private ";

	private static final String FROM = "from inquiries i join members m on i.writer = m.id ";

	private InquiryDTO toDto(ResultSet rs) throws Exception {

		InquiryDTO dto = new InquiryDTO();
		dto.setInquiryId(rs.getInt("inquiry_id"));
		dto.setTitle(rs.getString("title"));
		dto.setContent(rs.getString("content"));
		dto.setWriter(rs.getString("writer"));
		dto.setWriterNick(rs.getString("writer_nick"));
		dto.setRegDate(rs.getString("reg_date"));
		dto.setPrivate("Y".equals(rs.getString("is_private")));
		return dto;
	}

	//최신순 목록 - 공개 글 전부 + (로그인했다면) 본인이 쓴 비공개 글 + (관리자라면) 모든 비공개 글.
	//keyword가 있으면 제목/내용에서 검색(목록은 제목만 보여주지만, 내용으로도 찾을 수 있게 함).
	public List<InquiryDTO> getList(String viewerId, boolean isAdmin, String keyword) {

		boolean hasKeyword = keyword != null && !keyword.trim().isEmpty();

		String sql = "select " + COLUMNS + FROM
				   + "where (i.is_private = 'N' or i.writer = ? or ? = 'Y') "
				   + (hasKeyword ? "and (i.title like ? or i.content like ?) " : "")
				   + "order by i.inquiry_id desc";

		List<InquiryDTO> list = new ArrayList<InquiryDTO>();

		try (Connection conn = DBUtil.getInstance();
			 PreparedStatement pstmt = conn.prepareStatement(sql)) {

			int idx = 1;
			pstmt.setString(idx++, viewerId);   // 로그인 안 했으면 null -> "writer = null"은 항상 거짓이라 안전
			pstmt.setString(idx++, isAdmin ? "Y" : "N");
			if (hasKeyword) {
				String likeKeyword = "%" + keyword.trim() + "%";
				pstmt.setString(idx++, likeKeyword);
				pstmt.setString(idx++, likeKeyword);
			}

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

	//상세보기 - 없는 번호면 null. 비공개 글 권한 검사는 Command에서 한다(작성자/writer 정보가 필요해서).
	public InquiryDTO getById(int inquiryId) {

		String sql = "select " + COLUMNS + FROM + "where i.inquiry_id = ?";

		InquiryDTO dto = null;

		try (Connection conn = DBUtil.getInstance();
			 PreparedStatement pstmt = conn.prepareStatement(sql)) {

			pstmt.setInt(1, inquiryId);
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

	public int insert(String title, String content, String writer, boolean isPrivate) {

		String seqSql = "select seq_inquiries.nextval from dual";
		String sql = "insert into inquiries(inquiry_id, title, content, writer, is_private) values(?, ?, ?, ?, ?)";

		int inquiryId = 0;

		try (Connection conn = DBUtil.getInstance();
			 PreparedStatement seqPstmt = conn.prepareStatement(seqSql);
			 PreparedStatement pstmt = conn.prepareStatement(sql)) {

			try (ResultSet rs = seqPstmt.executeQuery()) {
				if (rs.next()) {
					inquiryId = rs.getInt(1);
				}
			}

			pstmt.setInt(1, inquiryId);
			pstmt.setString(2, title);
			pstmt.setString(3, content);
			pstmt.setString(4, writer);
			pstmt.setString(5, isPrivate ? "Y" : "N");

			if (pstmt.executeUpdate() == 0) {
				inquiryId = 0;
			}

		} catch (Exception e) {
			System.out.println(e.getMessage());
			inquiryId = 0;
		}

		return inquiryId;
	}

}
