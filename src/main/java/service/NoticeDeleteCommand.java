package service;

import java.io.IOException;
import java.io.PrintWriter;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.NoticeDAO;
import util.ParamUtil;

/**
 * 공지사항 삭제(Ajax, POST /admin/notices/delete). 관리자만 접근 가능 (AdminController에서 검사).
 */
public class NoticeDeleteCommand implements Command {

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		response.setContentType("application/json; charset=utf-8");
		PrintWriter out = response.getWriter();

		int noticeId = ParamUtil.toInt(request.getParameter("noticeId"), 0);

		if (new NoticeDAO().delete(noticeId) == 0) {
			out.print("{\"result\":\"fail\"}");
			return false;
		}

		out.print("{\"result\":\"ok\"}");
		return false;
	}

}
