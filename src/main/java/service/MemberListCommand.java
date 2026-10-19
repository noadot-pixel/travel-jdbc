package service;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.MemberDAO;

/**
 * 회원 목록(GET /admin/members). 관리자만 접근 가능 (AdminController에서 검사).
 */
public class MemberListCommand implements Command {

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		request.setAttribute("memberList", new MemberDAO().getAllMembers());

		return true;   // admin/members.jsp로 forward
	}

}
