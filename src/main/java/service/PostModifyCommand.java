package service;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.MemberDTO;
import model.PostDAO;
import model.PostDTO;
import model.PostLogDAO;
import util.HtmlSanitizer;
import util.ParamUtil;

/**
 * 게시글 수정 저장(POST /post/modify). 본문은 에디터(Quill)가 만든 HTML이라
 * 저장 전에 HtmlSanitizer로 한 번 거르고, 목록 카드 썸네일도 수정된 본문 기준으로 다시 계산한다.
 */
public class PostModifyCommand implements Command {

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		MemberDTO loginMember = (MemberDTO) request.getSession().getAttribute("loginMember");

		int bno = ParamUtil.toInt(request.getParameter("bno"), 0);

		PostDAO postDAO = new PostDAO();
		PostDTO original = postDAO.getPost(bno);

		if (original == null) {
			response.sendRedirect(request.getContextPath() + "/post/list");
			return false;
		}

		boolean isModerator = loginMember.isModerator();

		if (!loginMember.getId().equals(original.getWriter()) && !isModerator) {
			request.getSession().setAttribute("flashMsg", "본인이 작성한 게시글만 수정할 수 있습니다.");
			response.sendRedirect(request.getContextPath() + "/post/view?bno=" + bno);
			return false;
		}

		String title = request.getParameter("writeTitle");
		String content = request.getParameter("writeBody");
		String country = request.getParameter("country");
		String region = request.getParameter("region");
		String style = request.getParameter("style");

		boolean regionRequired = "KR".equals(country) || "JP".equals(country);

		if (isBlank(title) || HtmlSanitizer.isBlank(content) || isBlank(country) || isBlank(style)
				|| (regionRequired && isBlank(region))) {
			request.setAttribute("post", original);
			request.setAttribute("msg", "제목, 본문, 여행지 구분, 지역, 여행 성향을 모두 입력해 주세요.");
			return true;   // posts/edit.jsp로 다시 forward
		}

		//에디터가 보낸 HTML은 저장 전에 반드시 한 번 걸러야 한다 (HtmlSanitizer 클래스 설명 참고).
		String cleanContent = HtmlSanitizer.clean(content);
		String imgPath = PostWriteCommand.thumbnailFromContent(cleanContent, request.getContextPath(), country);

		PostDTO dto = new PostDTO();
		dto.setBno(bno);
		dto.setWriter(original.getWriter());   // 작성자는 바꾸지 않는다
		dto.setTitle(title.trim());
		dto.setContent(cleanContent);
		dto.setCountry(country);
		dto.setRegion(regionRequired ? region : null);   // ETC로 바꾸면 이전 지역값은 버린다
		dto.setStyle(style);
		dto.setImgPath(imgPath);

		//일반 회원은 본인 글만(where writer=?), 관리자는 전부 수정 가능
		int updatedRows = isModerator ? postDAO.updateByAdmin(dto) : postDAO.update(dto);

		if (updatedRows == 0) {
			request.setAttribute("post", original);
			request.setAttribute("msg", "게시글 수정에 실패했습니다.");
			return true;
		}

		//로그의 "작업자"는 실제로 이 수정을 실행한 사람(관리자일 수도 있음)으로 남긴다.
		new PostLogDAO().insert("UPDATE", bno, dto.getTitle(), loginMember.getId());

		response.sendRedirect(request.getContextPath() + "/post/view?bno=" + bno);
		return false;
	}

	private boolean isBlank(String s) {
		return s == null || s.trim().isEmpty();
	}

}
