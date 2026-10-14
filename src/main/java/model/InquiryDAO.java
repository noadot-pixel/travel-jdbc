package model;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import util.DBUtil;

/**
 * INQUIRIES 테이블(문의하기 게시판)을 다루는 DAO. 답변 기능은 없고, 누구나 보고
 * 로그인한 회원이면 남길 수 있는 단순 게시판이다.
 */
public class InquiryDAO {

	private static final String COLUMNS =
			"i.inquiry_id, i.title, i.content, i.writer, m.nickname writer_nick, "
		  + "to_char(i.reg_date, 'YYYY-MM-DD HH24:MI') reg_date ";

	private InquiryDTO toDto(ResultSet rs) throws Exception {

		InquiryDTO dto = new InquiryDTO();
		dto.setInquiryId(rs.getInt("inquiry_id"));
		dto.setTitle(rs.getString("title"));
		dto.setContent(rs.getString("content"));
		dto.setWriter(rs.getString("writer"));
		dto.setWriterNick(rs.getString("writer_nick"));
		dto.setRegDate(rs.getString("reg_date"));
		return dto;
	}

	//최신순 전체 목록
	public List<InquiryDTO> getList() {

		String sql = "select " + COLUMNS
				   + "from inquiries i join members m on i.writer = m.id "
				   + "order by i.inquiry_id desc";

		List<InquiryDTO> list = new ArrayList<InquiryDTO>();

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

	public int insert(String title, String content, String writer) {

		String seqSql = "select seq_inquiries.nextval from dual";
		String sql = "insert into inquiries(inquiry_id, title, content, writer) values(?, ?, ?, ?)";

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
