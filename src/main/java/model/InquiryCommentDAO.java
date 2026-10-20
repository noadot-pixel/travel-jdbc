package model;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import util.DBUtil;

/**
 * INQUIRY_COMMENTS 테이블을 다루는 DAO. 일반 게시글 댓글(CommentDAO)과 달리 누구나 달 수
 * 있는 게 아니라, 그 문의의 작성자 본인과 moderator 이상만 남길 수 있다 - 권한 검사는
 * InquiryCommentWriteCommand에서 하고, 여기는 SQL만 실행한다.
 */
public class InquiryCommentDAO {

	private InquiryCommentDTO toDto(ResultSet rs) throws Exception {

		InquiryCommentDTO dto = new InquiryCommentDTO();
		dto.setInquiryCommentId(rs.getInt("inquiry_comment_id"));
		dto.setInquiryId(rs.getInt("inquiry_id"));
		dto.setWriter(rs.getString("writer"));
		dto.setWriterNick(rs.getString("writer_nick"));
		dto.setContent(rs.getString("content"));
		dto.setRegDate(rs.getString("reg_date"));
		return dto;
	}

	//문의 하나의 댓글 전체 (작성 순)
	public List<InquiryCommentDTO> getList(int inquiryId) {

		String sql = "select c.inquiry_comment_id, c.inquiry_id, c.writer, m.nickname writer_nick, c.content, "
				   + "to_char(c.reg_date, 'YYYY-MM-DD HH24:MI') reg_date "
				   + "from inquiry_comments c join members m on c.writer = m.id "
				   + "where c.inquiry_id = ? order by c.inquiry_comment_id asc";

		List<InquiryCommentDTO> list = new ArrayList<InquiryCommentDTO>();

		try (Connection conn = DBUtil.getInstance();
			 PreparedStatement pstmt = conn.prepareStatement(sql)) {

			pstmt.setInt(1, inquiryId);
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

	public int insert(int inquiryId, String writer, String content) {

		String seqSql = "select seq_inquiry_comments.nextval from dual";
		String sql = "insert into inquiry_comments(inquiry_comment_id, inquiry_id, writer, content) values(?, ?, ?, ?)";

		int inquiryCommentId = 0;

		try (Connection conn = DBUtil.getInstance();
			 PreparedStatement seqPstmt = conn.prepareStatement(seqSql);
			 PreparedStatement pstmt = conn.prepareStatement(sql)) {

			try (ResultSet rs = seqPstmt.executeQuery()) {
				if (rs.next()) {
					inquiryCommentId = rs.getInt(1);
				}
			}

			pstmt.setInt(1, inquiryCommentId);
			pstmt.setInt(2, inquiryId);
			pstmt.setString(3, writer);
			pstmt.setString(4, content);

			if (pstmt.executeUpdate() == 0) {
				inquiryCommentId = 0;
			}

		} catch (Exception e) {
			System.out.println(e.getMessage());
			inquiryCommentId = 0;
		}

		return inquiryCommentId;
	}

}
