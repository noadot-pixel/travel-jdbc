package service;

import java.io.IOException;
import java.io.PrintWriter;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.MemberDTO;
import model.NoticeDAO;
import util.HtmlSanitizer;

/**
 * 공지사항 등록(Ajax, POST /admin/notices/create). 관리자만 접근 가능 (AdminController에서 검사).
 * 내용은 에디터(Quill)가 만든 HTML이라 저장 전에 HtmlSanitizer로 한 번 거른다.
 */
public class NoticeCreateCommand implements Command {

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		response.setContentType("application/json; charset=utf-8");
		PrintWriter out = response.getWriter();

		MemberDTO loginMember = (MemberDTO) request.getSession().getAttribute("loginMember");

		String title = request.getParameter("title");
		String content = request.getParameter("content");

		if (title == null || title.trim().isEmpty() || HtmlSanitizer.isBlank(content)) {
			out.print("{\"result\":\"empty\"}");
			return false;
		}

		int noticeId = new NoticeDAO().insert(title.trim(), HtmlSanitizer.clean(content), loginMember.getId());

		if (noticeId == 0) {
			out.print("{\"result\":\"fail\"}");
			return false;
		}

		out.print("{\"result\":\"ok\",\"noticeId\":" + noticeId + "}");
		return false;
	}

}
