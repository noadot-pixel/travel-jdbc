package service;

import java.io.IOException;
import java.io.PrintWriter;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.MemberDAO;

/**
 * 아이디(이메일) 중복 확인(Ajax, GET /member/idCheck) - 가입 화면에서 이메일 입력란을
 * 벗어날 때(blur) 호출한다. JoinCommand가 제출 시점에도 같은 검사를 다시 하므로,
 * 이건 어디까지나 사용자 편의(미리 알려주기)일 뿐 보안 경계가 아니다.
 */
public class IdCheckCommand implements Command {

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		response.setContentType("application/json; charset=utf-8");
		PrintWriter out = response.getWriter();

		String email = request.getParameter("id");

		if (email == null || email.trim().isEmpty()) {
			out.print("{\"result\":\"fail\"}");
			return false;
		}

		email = email.trim();

		if (!email.matches("^[\\w.+-]+@[\\w-]+\\.[\\w.-]+$")) {
			out.print("{\"result\":\"invalid\"}");
			return false;
		}

		boolean duplicate = new MemberDAO().idCheck(email);

		out.print("{\"result\":\"" + (duplicate ? "duplicate" : "available") + "\"}");
		return false;
	}

}
