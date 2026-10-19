package service;

import java.io.IOException;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.MemberDAO;
import model.MemberDTO;
import model.PostDAO;
import model.PostDTO;

/**
 * 다른 회원의 공개 프로필(GET /member/profile?id=). 로그인 없이 누구나 볼 수 있다.
 * 실명/생일/성별은 그 회원이 공개로 설정했을 때만 member/profile.jsp에서 보여준다
 * (자기소개/국가/프로필사진은 이 사이트에 애초에 공개 비공개 설정이 없어서 항상 보여줌,
 * 마이페이지 본인 화면과 같은 기준).
 */
public class MemberProfileCommand implements Command {

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		String id = request.getParameter("id");

		MemberDTO profileMember = (id == null) ? null : new MemberDAO().getById(id);

		if (profileMember == null) {
			response.sendRedirect(request.getContextPath() + "/main");
			return false;
		}

		List<PostDTO> posts = new PostDAO().getListByWriter(profileMember.getId());

		request.setAttribute("profileMember", profileMember);
		request.setAttribute("posts", posts);

		return true;   // member/profile.jsp로 forward
	}

}
