package controller;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import service.Command;
import service.NotificationListCommand;

/**
 * 알림 벨 관련 요청(Ajax, JSON 응답). 로그인 여부는 Command 안에서 확인한다
 * (PostController의 /post/like, /post/scrap과 같은 방식).
 */
@WebServlet({"/notification/list"})
public class NotificationController extends HttpServlet {

	private static final long serialVersionUID = 1L;

	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doAction(request, response);
	}

	protected void doAction(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		request.setCharacterEncoding("UTF-8");

		Command cmd = null;

		switch (request.getServletPath()) {
			case "/notification/list": {
				cmd = new NotificationListCommand();
				break;
			}
		}

		if (cmd != null) {
			cmd.doCommand(request, response);
		}
	}

}
