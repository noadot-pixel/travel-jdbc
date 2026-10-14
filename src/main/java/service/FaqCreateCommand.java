package service;

import java.io.IOException;
import java.io.PrintWriter;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.FaqDAO;
import model.MemberDTO;

/**
 * FAQ 등록(Ajax, POST /admin/faqs/create). 관리자만 접근 가능 (AdminController에서 검사).
 */
public class FaqCreateCommand implements Command {

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		response.setContentType("application/json; charset=utf-8");
		PrintWriter out = response.getWriter();

		MemberDTO loginMember = (MemberDTO) request.getSession().getAttribute("loginMember");

		String question = request.getParameter("question");
		String answer = request.getParameter("answer");

		if (question == null || question.trim().isEmpty() || answer == null || answer.trim().isEmpty()) {
			out.print("{\"result\":\"empty\"}");
			return false;
		}

		int faqId = new FaqDAO().insert(question.trim(), answer.trim(), loginMember.getId());

		if (faqId == 0) {
			out.print("{\"result\":\"fail\"}");
			return false;
		}

		out.print("{\"result\":\"ok\",\"faqId\":" + faqId + "}");
		return false;
	}

}
