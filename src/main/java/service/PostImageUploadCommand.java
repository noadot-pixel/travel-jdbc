package service;

import java.io.IOException;
import java.io.PrintWriter;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import model.MemberDTO;
import util.EscapeUtil;
import util.UploadUtil;

/**
 * 글쓰기/수정 에디터(Quill)에서 본문 중간에 이미지를 끼워 넣을 때 쓰는 업로드
 * 엔드포인트(Ajax, POST /post/uploadImage). 에디터가 이 API로 파일을 올리고,
 * 돌려받은 URL을 커서 위치에 &lt;img&gt;로 바로 삽입한다.
 */
public class PostImageUploadCommand implements Command {

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		response.setContentType("application/json; charset=utf-8");
		PrintWriter out = response.getWriter();

		MemberDTO loginMember = (MemberDTO) request.getSession().getAttribute("loginMember");

		if (loginMember == null) {
			out.print("{\"result\":\"login\"}");
			return false;
		}

		Part part = request.getPart("image");
		String path = UploadUtil.save(part, request.getServletContext(), "post");

		if (path == null) {
			out.print("{\"result\":\"fail\"}");
			return false;
		}

		String url = request.getContextPath() + "/" + path;

		out.print("{\"result\":\"ok\",\"url\":\"" + EscapeUtil.json(url) + "\"}");
		return false;
	}

}
