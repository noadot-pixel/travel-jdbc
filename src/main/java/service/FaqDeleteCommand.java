package service;

import java.io.IOException;
import java.io.PrintWriter;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.FaqDAO;
import util.ParamUtil;

/**
 * FAQ 삭제(Ajax, POST /admin/faqs/delete). 관리자만 접근 가능 (AdminController에서 검사).
 */
public class FaqDeleteCommand implements Command {

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		response.setContentType("application/json; charset=utf-8");
		PrintWriter out = response.getWriter();

		int faqId = ParamUtil.toInt(request.getParameter("faqId"), 0);

		if (new FaqDAO().delete(faqId) == 0) {
			out.print("{\"result\":\"fail\"}");
			return false;
		}

		out.print("{\"result\":\"ok\"}");
		return false;
	}

}
