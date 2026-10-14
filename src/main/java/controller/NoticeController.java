package controller;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import service.Command;
import service.NoticePublicListCommand;
import service.NoticeViewCommand;

/**
 * 공지사항 공개 화면(목록 - 푸터 "공지사항" 링크 / 상세 - 알림 벨에서 클릭). 로그인 불필요.
 */
@WebServlet({"/notice/list", "/notice/view"})
public class NoticeController extends HttpServlet {

	private static final long serialVersionUID = 1L;

	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		request.setCharacterEncoding("UTF-8");

		String path = request.getServletPath();
		Command cmd;
		String page;

		if ("/notice/view".equals(path)) {
			cmd = new NoticeViewCommand();
			page = "/notice/view.jsp";
		} else {
			cmd = new NoticePublicListCommand();
			page = "/notice/list.jsp";
		}

		boolean isForward = cmd.doCommand(request, response);

		if (isForward) {
			request.getRequestDispatcher(page).forward(request, response);
		}
	}

}
