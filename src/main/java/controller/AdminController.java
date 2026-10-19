package controller;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.MemberDTO;
import service.Command;
import service.NoOpCommand;
import service.FaqCreateCommand;
import service.FaqDeleteCommand;
import service.FaqListCommand;
import service.FaqUpdateCommand;
import service.MemberGrantAdminCommand;
import service.MemberListCommand;
import service.MemberSuspendCommand;
import service.NoticeCreateCommand;
import service.NoticeDeleteCommand;
import service.NoticeListCommand;
import service.PostLogListCommand;
import service.SeedCommand;

/**
 * 관리자 전용 요청(게시글 로그, 예시 게시글 시드 추가, 공지사항 관리, FAQ 관리, 회원 관리).
 * 로그인 + 모더레이터 이상(ADMIN_LEVEL >= 1)인지를 여기서 한 번에 검사한다.
 * 그중 권한 레벨 변경(/admin/members/setLevel)만 admin(레벨 2)으로 한 번 더 좁혀서
 * MemberGrantAdminCommand 안에서 검사한다.
 */
@WebServlet({"/admin/postLogs", "/admin/seed",
			 "/admin/notices", "/admin/notices/create", "/admin/notices/delete",
			 "/admin/faqs", "/admin/faqs/create", "/admin/faqs/update", "/admin/faqs/delete",
			 "/admin/members", "/admin/members/suspend", "/admin/members/setLevel", "/admin"})
public class AdminController extends HttpServlet {

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

		MemberDTO loginMember = (MemberDTO) request.getSession().getAttribute("loginMember");

		if (loginMember == null) {
			response.sendRedirect(request.getContextPath() + "/member/login");
			return;
		}

		if (!loginMember.isModerator()) {
			response.sendRedirect(request.getContextPath() + "/main");
			return;
		}

		switch (path) {
			case "/admin/postLogs": {
				cmd = new PostLogListCommand();
				page = "/admin/post-logs.jsp";
				break;
			}
			case "/admin/seed": {                         // Ajax - JSON 응답
				cmd = new SeedCommand();
				break;
			}
			case "/admin/notices": {
				cmd = new NoticeListCommand();
				page = "/admin/notices.jsp";
				break;
			}
			case "/admin/notices/create": {               // Ajax - JSON 응답
				cmd = new NoticeCreateCommand();
				break;
			}
			case "/admin/notices/delete": {                // Ajax - JSON 응답
				cmd = new NoticeDeleteCommand();
				break;
			}
			case "/admin/faqs": {
				cmd = new FaqListCommand();
				page = "/admin/faqs.jsp";
				break;
			}
			case "/admin/faqs/create": {                   // Ajax - JSON 응답
				cmd = new FaqCreateCommand();
				break;
			}
			case "/admin/faqs/update": {                   // Ajax - JSON 응답
				cmd = new FaqUpdateCommand();
				break;
			}
			case "/admin/faqs/delete": {                   // Ajax - JSON 응답
				cmd = new FaqDeleteCommand();
				break;
			}
			case "/admin/members": {
				cmd = new MemberListCommand();
				page = "/admin/members.jsp";
				break;
			}
			case "/admin/members/suspend": {               // Ajax - JSON 응답
				cmd = new MemberSuspendCommand();
				break;
			}
			case "/admin/members/setLevel": {              // Ajax - JSON 응답
				cmd = new MemberGrantAdminCommand();
				break;
			}
			case "/admin": {
				cmd = new NoOpCommand();
				page = "/admin/index.jsp";
				break;
			}
		}

		boolean isForward = true;
		if (cmd != null) {
			isForward = cmd.doCommand(request, response);
		}

		if (isForward && page != null) {
			request.getRequestDispatcher(page).forward(request, response);
		}
	}

}
