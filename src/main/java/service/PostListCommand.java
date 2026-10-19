package service;

import java.io.IOException;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.PostDAO;
import model.PostDTO;
import util.ParamUtil;

/**
 * 게시글 목록(GET /post/list). 국가/성향 필터 + 제목 검색 + 정렬(최신순/인기순)을
 * 전부 쿼리 파라미터로 받아 SQL에서 처리한다. 한 번에 PostDAO.PAGE_SIZE(20)개씩
 * 페이지네이션한다.
 */
public class PostListCommand implements Command {

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		String country = request.getParameter("country");
		String style = request.getParameter("style");
		String region = request.getParameter("region");
		String keyword = request.getParameter("keyword");
		String sort = request.getParameter("sort");   // "latest"(기본) 또는 "popular"
		int page = ParamUtil.toInt(request.getParameter("page"), 1);

		if (country == null) country = "ALL";
		if (style == null) style = "ALL";
		//다른 국가로 바꿨는데 이전 지역값이 그대로 남아 있으면 안 되므로, country가 KR/JP가
		//아니면(또는 전체면) region도 강제로 전체로 되돌린다.
		if (region == null || !("KR".equals(country) || "JP".equals(country))) region = "ALL";
		if (keyword == null) keyword = "";
		if (page < 1) page = 1;

		PostDAO dao = new PostDAO();

		List<PostDTO> list = "popular".equals(sort)
			? dao.getPopularList(country, style, region, keyword, page)
			: dao.getList(country, style, region, keyword, page);

		int totalCount = dao.getCount(country, style, region, keyword);
		int totalPages = (totalCount + PostDAO.PAGE_SIZE - 1) / PostDAO.PAGE_SIZE;
		if (totalPages < 1) totalPages = 1;

		request.setAttribute("list", list);
		request.setAttribute("country", country);
		request.setAttribute("style", style);
		request.setAttribute("region", region);
		request.setAttribute("keyword", keyword);
		request.setAttribute("sort", sort == null ? "latest" : sort);
		request.setAttribute("page", page);
		request.setAttribute("totalPages", totalPages);
		request.setAttribute("totalCount", totalCount);

		return true;   // posts.jsp로 forward
	}

}
