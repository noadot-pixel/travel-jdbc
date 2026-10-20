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
 * 완전히 정적인 공개 페이지(개인정보처리방침). 로그인 불필요.
 * /about은 더 이상 이 사이트 안에 소개 페이지를 따로 두지 않고, 발표자료/데모/라이브 사이트를
 * 한데 모아둔 포트폴리오 GitHub Pages로 바로 리다이렉트한다(about.jsp는 삭제함).
 */
@WebServlet({"/about", "/privacy"})
public class PageController extends HttpServlet {

	private static final long serialVersionUID = 1L;

	private static final String PORTFOLIO_URL = "https://noadot-pixel.github.io/travel-portfolio/";

	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		String path = request.getServletPath();

		if ("/about".equals(path)) {
			response.sendRedirect(PORTFOLIO_URL);
			return;
		}

		Command cmd = new NoOpCommand();
		boolean isForward = cmd.doCommand(request, response);

		if (isForward) {
			request.getRequestDispatcher("/auth/privacy.jsp").forward(request, response);
		}
	}

}
