package service;

import java.io.IOException;
import java.io.PrintWriter;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.MemberDTO;
import model.NotificationDAO;
import model.PostDAO;
import util.ParamUtil;

/**
 * 좋아요 누르기/취소(Ajax, POST /post/like) - JSON으로 응답.
 * 응답 예: {"result":"ok","liked":true,"likeCnt":4}
 *         {"result":"login"}  ← 로그인 안 한 경우
 */
public class LikeCommand implements Command {

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		response.setContentType("application/json; charset=utf-8");
		PrintWriter out = response.getWriter();

		MemberDTO loginMember = (MemberDTO) request.getSession().getAttribute("loginMember");

		if (loginMember == null) {
			//Ajax 요청은 sendRedirect로 로그인 페이지에 보내도 화면이 안 바뀐다
			//→ JSON으로 "로그인 필요"를 알려주고, 이동은 JS가 하게 한다.
			out.print("{\"result\":\"login\"}");
			return false;
		}

		int bno = ParamUtil.toInt(request.getParameter("bno"), 0);
		PostDAO dao = new PostDAO();

		if (!dao.toggleLike(bno, loginMember.getId())) {
			out.print("{\"result\":\"fail\"}");
			return false;
		}

		boolean liked = dao.isLiked(bno, loginMember.getId());
		int likeCnt = dao.getLikeCnt(bno);

		//좋아요를 누른 경우에만 알림 (취소할 때는 알리지 않는다. 자기 글이면 insert()가 알아서 건너뛴다)
		if (liked) {
			String postWriter = dao.getWriter(bno);
			if (postWriter != null) {
				new NotificationDAO().insert(postWriter, "LIKE", bno, loginMember.getId());
			}
		}

		out.print("{\"result\":\"ok\",\"liked\":" + liked + ",\"likeCnt\":" + likeCnt + "}");
		return false;
	}

}
