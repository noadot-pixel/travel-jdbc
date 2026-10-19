package service;

import java.io.IOException;
import java.util.Collections;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.CommentDAO;
import model.CommentDTO;
import model.MemberDTO;
import model.PostDAO;
import model.PostDTO;
import util.ParamUtil;

/**
 * 마이페이지(보기 전용, GET /member/mypage).
 * 세션에 이미 있는 프로필(loginMember)에 더해, 라디오로 고른 활동 종류(게시글/댓글/스크랩)
 * 하나만 검색+페이지네이션(10개씩)해서 보여준다.
 */
public class MypageCommand implements Command {

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		MemberDTO loginMember = (MemberDTO) request.getSession().getAttribute("loginMember");

		String type = request.getParameter("type");       // "post"(기본) | "comment" | "scrap"
		String keyword = request.getParameter("keyword");
		int page = ParamUtil.toInt(request.getParameter("page"), 1);

		if (type == null
				|| !("post".equals(type) || "comment".equals(type) || "scrap".equals(type))) {
			type = "post";
		}
		if (keyword == null) keyword = "";
		if (page < 1) page = 1;

		String memberId = loginMember.getId();

		List<PostDTO> postList = Collections.emptyList();
		List<CommentDTO> commentList = Collections.emptyList();
		int totalCount;

		if ("comment".equals(type)) {
			CommentDAO commentDAO = new CommentDAO();
			commentList = commentDAO.getListByWriter(memberId, keyword, page);
			totalCount = commentDAO.getCountByWriter(memberId, keyword);
		} else {
			PostDAO postDAO = new PostDAO();
			if ("scrap".equals(type)) {
				postList = postDAO.getScrappedList(memberId, keyword, page);
				totalCount = postDAO.getScrappedCount(memberId, keyword);
			} else {
				postList = postDAO.getListByWriter(memberId, keyword, page);
				totalCount = postDAO.getCountByWriter(memberId, keyword);
			}
		}

		int totalPages = (totalCount + PostDAO.MYPAGE_PAGE_SIZE - 1) / PostDAO.MYPAGE_PAGE_SIZE;
		if (totalPages < 1) totalPages = 1;

		request.setAttribute("activityType", type);
		request.setAttribute("keyword", keyword);
		request.setAttribute("page", page);
		request.setAttribute("totalPages", totalPages);
		request.setAttribute("totalCount", totalCount);
		request.setAttribute("postList", postList);
		request.setAttribute("commentList", commentList);

		return true;   // mypage.jsp로 forward
	}

}
