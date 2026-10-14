package controller;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.MemberDTO;
import service.Command;
import service.InquiryWriteCommand;
import service.SupportPageCommand;

/**
 * 자주 묻는 질문 + 문의하기(/support). 글 작성(/support/write)만 로그인이 필요하다.
 */
@WebServlet({"/support", "/support/write"})
public class SupportController extends HttpServlet {

	private static final long serialVersionUID = 1L;

	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doAction(request, response);
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doAction(request, response);
	}

	protected void doAction(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		request.setCharacterEncoding("UTF-8");

		String path = request.getServletPath();
		String page = null;
		Command cmd = null;

		if ("/support/write".equals(path)) {

			MemberDTO loginMember = (MemberDTO) request.getSession().getAttribute("loginMember");

			if (loginMember == null) {
				response.sendRedirect(request.getContextPath() + "/member/login");
				return;
			}

			cmd = new InquiryWriteCommand();
			page = "/support.jsp";

		} else {
			cmd = new SupportPageCommand();
			page = "/support.jsp";
		}

		boolean isForward = cmd.doCommand(request, response);

		if (isForward && page != null) {
			request.getRequestDispatcher(page).forward(request, response);
		}
	}

}
