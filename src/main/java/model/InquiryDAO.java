package model;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import util.DBUtil;

/**
 * INQUIRIES 테이블(문의하기 게시판)을 다루는 DAO. 답변 기능은 없고, 로그인한 회원이면
 * 남길 수 있는 게시판이다. 비공개로 남긴 글은 작성자 본인과 관리자만 볼 수 있다.
 */
public class InquiryDAO {

	private static final String COLUMNS =
			"i.inquiry_id, i.title, i.content, i.writer, m.nickname writer_nick, "
		  + "to_char(i.reg_date, 'YYYY-MM-DD HH24:MI') reg_date, i.is_private ";

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

	//최신순 목록 - 공개 글 전부 + (로그인했다면) 본인이 쓴 비공개 글 + (관리자라면) 모든 비공개 글
	public List<InquiryDTO> getList(String viewerId, boolean isAdmin) {

		String sql = "select " + COLUMNS
				   + "from inquiries i join members m on i.writer = m.id "
				   + "where i.is_private = 'N' or i.writer = ? or ? = 'Y' "
				   + "order by i.inquiry_id desc";

		List<InquiryDTO> list = new ArrayList<InquiryDTO>();

		try (Connection conn = DBUtil.getInstance();
			 PreparedStatement pstmt = conn.prepareStatement(sql)) {

			pstmt.setString(1, viewerId);   // 로그인 안 했으면 null -> "writer = null"은 항상 거짓이라 안전
			pstmt.setString(2, isAdmin ? "Y" : "N");

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
