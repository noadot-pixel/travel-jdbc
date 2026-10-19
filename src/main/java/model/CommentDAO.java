package model;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import util.DBUtil;

/**
 * COMMENTS 테이블을 다루는 DAO.
 */
public class CommentDAO {

	private CommentDTO toDto(ResultSet rs) throws Exception {

		CommentDTO dto = new CommentDTO();
		dto.setCno(rs.getInt("cno"));
		dto.setBno(rs.getInt("bno"));
		dto.setWriter(rs.getString("writer"));
		dto.setWriterNick(rs.getString("writer_nick"));
		dto.setContent(rs.getString("content"));
		dto.setRegDate(rs.getString("reg_date"));
		return dto;
	}

	//게시글 하나의 댓글 전체 (작성 순)
	public List<CommentDTO> getList(int bno) {

		String sql = "select c.cno, c.bno, c.writer, m.nickname writer_nick, c.content, "
				   + "to_char(c.reg_date, 'YYYY-MM-DD HH24:MI') reg_date "
				   + "from comments c join members m on c.writer = m.id "
				   + "where c.bno = ? order by c.cno asc";

		List<CommentDTO> list = new ArrayList<CommentDTO>();

		try (Connection conn = DBUtil.getInstance();
			 PreparedStatement pstmt = conn.prepareStatement(sql)) {

			pstmt.setInt(1, bno);
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

	//댓글 삭제 권한(작성자/글 작성자/관리자) 검사를 위해 writer와 bno만 가볍게 조회한다.
	public CommentDTO getById(int cno) {

		String sql = "select c.cno, c.bno, c.writer, m.nickname writer_nick, c.content, "
				   + "to_char(c.reg_date, 'YYYY-MM-DD HH24:MI') reg_date "
				   + "from comments c join members m on c.writer = m.id "
				   + "where c.cno = ?";

		CommentDTO dto = null;

		try (Connection conn = DBUtil.getInstance();
			 PreparedStatement pstmt = conn.prepareStatement(sql)) {

			pstmt.setInt(1, cno);
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

	public int insert(int bno, String writer, String content) {

		String seqSql = "select seq_comments.nextval from dual";
		String sql = "insert into comments(cno, bno, writer, content) values(?, ?, ?, ?)";

		int cno = 0;

		try (Connection conn = DBUtil.getInstance();
			 PreparedStatement seqPstmt = conn.prepareStatement(seqSql);
			 PreparedStatement pstmt = conn.prepareStatement(sql)) {

			try (ResultSet rs = seqPstmt.executeQuery()) {
				if (rs.next()) {
					cno = rs.getInt(1);
				}
			}

			pstmt.setInt(1, cno);
			pstmt.setInt(2, bno);
			pstmt.setString(3, writer);
			pstmt.setString(4, content);

			if (pstmt.executeUpdate() == 0) {
				cno = 0;
			}

		} catch (Exception e) {
			System.out.println(e.getMessage());
			cno = 0;
		}

		return cno;
	}

	//권한 검사는 CommentDeleteCommand에서 미리 끝내고, 여기서는 번호로만 지운다.
	public int delete(int cno) {

		String sql = "delete from comments where cno = ?";

		int result = 0;

		try (Connection conn = DBUtil.getInstance();
			 PreparedStatement pstmt = conn.prepareStatement(sql)) {

			pstmt.setInt(1, cno);
			result = pstmt.executeUpdate();

		} catch (Exception e) {
			System.out.println(e.getMessage());
		}

		return result;
	}

	public static final int MYPAGE_PAGE_SIZE = 10;

	//마이페이지 "내가 쓴 댓글" - 내용 검색 + 페이지네이션. page는 1부터 시작.
	public List<CommentDTO> getListByWriter(String writer, String keyword, int page) {

		if (page < 1) page = 1;

		int startRow = (page - 1) * MYPAGE_PAGE_SIZE;
		int endRow = startRow + MYPAGE_PAGE_SIZE;

		boolean hasKeyword = keyword != null && !keyword.trim().isEmpty();

		String sql = "select * from ( "
				   + "  select a.*, rownum rnum from ( "
				   + "    select c.cno, c.bno, c.writer, m.nickname writer_nick, c.content, "
				   + "           p.title post_title, "
				   + "           to_char(c.reg_date, 'YYYY-MM-DD HH24:MI') reg_date "
				   + "    from comments c "
				   + "    join members m on c.writer = m.id "
				   + "    join posts p on c.bno = p.bno "
				   + "    where c.writer = ? "
				   + (hasKeyword ? "and c.content like ? " : "")
				   + "    order by c.cno desc "
				   + "  ) a where rownum <= ? "
				   + ") where rnum > ?";

		List<CommentDTO> list = new ArrayList<CommentDTO>();

		try (Connection conn = DBUtil.getInstance();
			 PreparedStatement pstmt = conn.prepareStatement(sql)) {

			int idx = 1;
			pstmt.setString(idx++, writer);
			if (hasKeyword) {
				pstmt.setString(idx++, "%" + keyword.trim() + "%");
			}
			pstmt.setInt(idx++, endRow);
			pstmt.setInt(idx++, startRow);

			try (ResultSet rs = pstmt.executeQuery()) {
				while (rs.next()) {
					CommentDTO dto = toDto(rs);
					dto.setPostTitle(rs.getString("post_title"));
					list.add(dto);
				}
			}

		} catch (Exception e) {
			System.out.println(e.getMessage());
		}

		return list;
	}

	public int getCountByWriter(String writer, String keyword) {

		boolean hasKeyword = keyword != null && !keyword.trim().isEmpty();

		String sql = "select count(*) from comments c where c.writer = ? "
				   + (hasKeyword ? "and c.content like ?" : "");

		int count = 0;

		try (Connection conn = DBUtil.getInstance();
			 PreparedStatement pstmt = conn.prepareStatement(sql)) {

			int idx = 1;
			pstmt.setString(idx++, writer);
			if (hasKeyword) {
				pstmt.setString(idx++, "%" + keyword.trim() + "%");
			}

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

	public int countByPost(int bno) {

		String sql = "select count(*) from comments where bno = ?";

		int count = 0;

		try (Connection conn = DBUtil.getInstance();
			 PreparedStatement pstmt = conn.prepareStatement(sql)) {

			pstmt.setInt(1, bno);
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

}
