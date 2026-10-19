package service;

import java.io.IOException;
import java.io.PrintWriter;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.MemberDAO;
import model.MemberDTO;

/**
 * 회원 활동 정지/해제(Ajax, POST /admin/members/suspend). 모더레이터 이상만 접근 가능
 * (AdminController에서 검사). 자기 자신이나 다른 모더레이터/관리자는 정지시킬 수 없다 -
 * 운영진끼리 서로 정지시켜서 묶이는 상황을 막는 안전장치.
 */
public class MemberSuspendCommand implements Command {

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		response.setContentType("application/json; charset=utf-8");
		PrintWriter out = response.getWriter();

		MemberDTO loginMember = (MemberDTO) request.getSession().getAttribute("loginMember");

		String targetId = request.getParameter("id");
		boolean suspend = "Y".equals(request.getParameter("suspend"));

		if (targetId == null || targetId.trim().isEmpty()) {
			out.print("{\"result\":\"fail\"}");
			return false;
		}

		if (targetId.equals(loginMember.getId())) {
			out.print("{\"result\":\"self\"}");
			return false;
		}

		MemberDAO dao = new MemberDAO();
		MemberDTO target = dao.getById(targetId);

		if (target == null) {
			out.print("{\"result\":\"fail\"}");
			return false;
		}

		if (target.isModerator()) {
			out.print("{\"result\":\"admin\"}");
			return false;
		}

		if (dao.setSuspended(targetId, suspend) == 0) {
			out.print("{\"result\":\"fail\"}");
			return false;
		}

		out.print("{\"result\":\"ok\",\"suspended\":" + suspend + "}");
		return false;
	}

}
