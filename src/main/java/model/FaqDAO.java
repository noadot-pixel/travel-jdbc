package model;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import util.DBUtil;

/**
 * FAQS 테이블(자주 묻는 질문)을 다루는 DAO. 등록한 관리자가 나중에 질문/답변을
 * 고칠 수 있어야 하므로 notices와 달리 update()가 있다.
 */
public class FaqDAO {

	private static final String COLUMNS =
			"f.faq_id, f.question, f.answer, f.writer, m.nickname writer_nick, "
		  + "to_char(f.reg_date, 'YYYY-MM-DD HH24:MI') reg_date, "
		  + "to_char(f.mod_date, 'YYYY-MM-DD HH24:MI') mod_date ";

	private FaqDTO toDto(ResultSet rs) throws Exception {

		FaqDTO dto = new FaqDTO();
		dto.setFaqId(rs.getInt("faq_id"));
		dto.setQuestion(rs.getString("question"));
		dto.setAnswer(rs.getString("answer"));
		dto.setWriter(rs.getString("writer"));
		dto.setWriterNick(rs.getString("writer_nick"));
		dto.setRegDate(rs.getString("reg_date"));
		dto.setModDate(rs.getString("mod_date"));
		return dto;
	}

	//등록 순(오래된 것부터) - 처음 만든 질문이 보통 가장 기본적인 질문이라 자연스럽게 위로 온다.
	public List<FaqDTO> getList() {

		String sql = "select " + COLUMNS
				   + "from faqs f join members m on f.writer = m.id "
				   + "order by f.faq_id asc";

		List<FaqDTO> list = new ArrayList<FaqDTO>();

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

	public int insert(String question, String answer, String writer) {

		String seqSql = "select seq_faqs.nextval from dual";
		String sql = "insert into faqs(faq_id, question, answer, writer) values(?, ?, ?, ?)";

		int faqId = 0;

		try (Connection conn = DBUtil.getInstance();
			 PreparedStatement seqPstmt = conn.prepareStatement(seqSql);
			 PreparedStatement pstmt = conn.prepareStatement(sql)) {

			try (ResultSet rs = seqPstmt.executeQuery()) {
				if (rs.next()) {
					faqId = rs.getInt(1);
				}
			}

			pstmt.setInt(1, faqId);
			pstmt.setString(2, question);
			pstmt.setString(3, answer);
			pstmt.setString(4, writer);

			if (pstmt.executeUpdate() == 0) {
				faqId = 0;
			}

		} catch (Exception e) {
			System.out.println(e.getMessage());
			faqId = 0;
		}

		return faqId;
	}

	public int update(int faqId, String question, String answer) {

		String sql = "update faqs set question = ?, answer = ?, mod_date = sysdate where faq_id = ?";

		int result = 0;

		try (Connection conn = DBUtil.getInstance();
			 PreparedStatement pstmt = conn.prepareStatement(sql)) {

			pstmt.setString(1, question);
			pstmt.setString(2, answer);
			pstmt.setInt(3, faqId);
			result = pstmt.executeUpdate();

		} catch (Exception e) {
			System.out.println(e.getMessage());
		}

		return result;
	}

	public int delete(int faqId) {

		String sql = "delete from faqs where faq_id = ?";

		int result = 0;

		try (Connection conn = DBUtil.getInstance();
			 PreparedStatement pstmt = conn.prepareStatement(sql)) {

			pstmt.setInt(1, faqId);
			result = pstmt.executeUpdate();

		} catch (Exception e) {
			System.out.println(e.getMessage());
		}

		return result;
	}

}
