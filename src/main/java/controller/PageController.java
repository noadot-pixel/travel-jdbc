package controller;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import service.Command;
import service.NoOpCommand;

/**
 * 완전히 정적인 공개 페이지(소개, 개인정보처리방침). 로그인 불필요.
 * 예전에는 about.jsp / auth/privacy.jsp를 직접 가리켰는데, 이 프로젝트의 다른 페이지들처럼
 * 깔끔한 주소(/about, /privacy)로 들어오도록 정리했다.
 */
@WebServlet({"/about", "/privacy"})
public class PageController extends HttpServlet {

	private static final long serialVersionUID = 1L;

	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		String path = request.getServletPath();
		String page = "/privacy".equals(path) ? "/auth/privacy.jsp" : "/about.jsp";

		Command cmd = new NoOpCommand();
		boolean isForward = cmd.doCommand(request, response);

		if (isForward) {
			request.getRequestDispatcher(page).forward(request, response);
		}
	}

}
