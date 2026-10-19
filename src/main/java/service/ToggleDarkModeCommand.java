package service;

import java.io.IOException;
import java.io.PrintWriter;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.MemberDAO;
import model.MemberDTO;

/**
 * 다크모드 켜기/끄기(Ajax, POST /member/toggleDarkMode). 마이페이지의 토글 스위치가 호출한다.
 * 세션의 loginMember도 바로 갱신해서, 다음 페이지 이동부터 곧바로 반영되게 한다.
 */
public class ToggleDarkModeCommand implements Command {

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		response.setContentType("application/json; charset=utf-8");
		PrintWriter out = response.getWriter();

		HttpSession session = request.getSession();
		MemberDTO loginMember = (MemberDTO) session.getAttribute("loginMember");

		if (loginMember == null) {
			out.print("{\"result\":\"login\"}");
			return false;
		}

		boolean on = "Y".equals(request.getParameter("on"));

		if (new MemberDAO().setDarkMode(loginMember.getId(), on) == 0) {
			out.print("{\"result\":\"fail\"}");
			return false;
		}

		loginMember.setDarkMode(on);
		session.setAttribute("loginMember", loginMember);

		out.print("{\"result\":\"ok\",\"darkMode\":" + on + "}");
		return false;
	}

}
