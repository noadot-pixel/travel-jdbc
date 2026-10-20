package service;

import java.io.IOException;
import java.io.PrintWriter;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.MemberDAO;
import model.MemberDTO;

/**
 * 닉네임 중복 확인(Ajax, GET /member/nicknameCheck) - 가입/프로필 수정 화면에서 쓴다.
 * 로그인 중이면(프로필 수정) 세션의 자기 계정은 자동으로 제외하고 검사한다.
 * IdCheckCommand(이메일 중복 확인)와 같은 이유로, 이것도 서버의 최종 검사(JoinCommand/
 * ProfileEditCommand)를 대체하지 않는 사용자 편의 기능일 뿐이다.
 */
public class NicknameCheckCommand implements Command {

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		response.setContentType("application/json; charset=utf-8");
		PrintWriter out = response.getWriter();

		String nickname = request.getParameter("nickname");

		if (nickname == null || !nickname.trim().matches("^[\\p{L}\\p{N}]{2,12}$")) {
			out.print("{\"result\":\"invalid\"}");
			return false;
		}

		MemberDTO loginMember = (MemberDTO) request.getSession().getAttribute("loginMember");
		String excludeId = loginMember == null ? null : loginMember.getId();

		boolean duplicate = new MemberDAO().nicknameCheck(nickname.trim(), excludeId);

		out.print("{\"result\":\"" + (duplicate ? "duplicate" : "available") + "\"}");
		return false;
	}

}
