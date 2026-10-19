package service;

import java.io.IOException;
import java.io.PrintWriter;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.MemberDAO;
import model.MemberDTO;
import util.ParamUtil;

/**
 * 권한 레벨 변경(Ajax, POST /admin/members/setLevel). AdminController는 모더레이터
 * 이상이면 전부 통과시키지만, 권한 레벨을 바꾸는 건 admin(레벨 2)만 할 수 있어야 하므로
 * 여기서 한 번 더 엄격하게 검사한다 - 이 검사 하나로 "모더레이터 지정도 admin만 가능"과
 * "모더레이터는 admin을 못 건드림" 둘 다 자동으로 만족된다(모더레이터는 애초에 이 요청
 * 자체를 보낼 수 없으므로).
 * 본인 계정은 여기서 바꿀 수 없다 - 실수로 자기 권한을 낮춰서 못 들어오게 되는 상황을
 * 막는 안전장치 (MemberSuspendCommand와 같은 이유).
 */
public class MemberGrantAdminCommand implements Command {

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		response.setContentType("application/json; charset=utf-8");
		PrintWriter out = response.getWriter();

		MemberDTO loginMember = (MemberDTO) request.getSession().getAttribute("loginMember");

		if (!loginMember.isAdmin()) {
			out.print("{\"result\":\"forbidden\"}");
			return false;
		}

		String targetId = request.getParameter("id");
		int level = ParamUtil.toInt(request.getParameter("level"), -1);

		if (targetId == null || targetId.trim().isEmpty() || level < 0 || level > 2) {
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

		if (dao.setAdminLevel(targetId, level) == 0) {
			out.print("{\"result\":\"fail\"}");
			return false;
		}

		out.print("{\"result\":\"ok\",\"level\":" + level + "}");
		return false;
	}

}
