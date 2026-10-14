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

/**
 * 글쓰기 폼 제출(POST /post/write). 본문은 에디터(Quill)가 만든 HTML이라 저장 전에
 * HtmlSanitizer로 한 번 거른다. 더 이상 별도 "사진 첨부"가 없고, 목록 카드 썸네일은
 * 본문 안 첫 번째 이미지를 그대로 쓴다(없으면 국가별 기본 이미지).
 */
public class PostWriteCommand implements Command {

	//본문에 이미지가 없을 때 국가별로 쓰는 기본 이미지 (main/webapp/images 안의 기존 파일)
	//PostModifyCommand도 그대로 쓰므로 package-private(기본 접근 제한자)으로 둔다.
	static String defaultImage(String country) {
		if ("KR".equals(country)) return "images/korea.jpg";
		if ("JP".equals(country)) return "images/japan.jpg";
		return "images/world.jpg";
	}

	//본문 첫 이미지를 목록 카드 썸네일 경로로 쓸 수 있게 정규화한다.
	//우리가 올린 이미지(/upload/post/xxx.jpg)가 아니면(예: 외부 주소) 안전하게 무시한다.
	static String thumbnailFromContent(String content, String contextPath, String country) {

		String src = HtmlSanitizer.firstImageSrc(content);

		if (src == null) {
			return defaultImage(country);
		}

		String prefix = contextPath + "/upload/";

		if (src.startsWith(prefix)) {
			return src.substring(contextPath.length() + 1);
		}

		return defaultImage(country);
	}

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		MemberDTO loginMember = (MemberDTO) request.getSession().getAttribute("loginMember");

		String title = request.getParameter("writeTitle");
		String content = request.getParameter("writeBody");
		String country = request.getParameter("country");
		String region = request.getParameter("region");
		String style = request.getParameter("style");

		//세부 지역은 국내/일본 여행일 때만 필수 - 해외(ETC)는 지역 구분을 안 받는다.
		boolean regionRequired = "KR".equals(country) || "JP".equals(country);

		if (isBlank(title) || HtmlSanitizer.isBlank(content) || isBlank(country) || isBlank(style)
				|| (regionRequired && isBlank(region))) {
			request.setAttribute("msg", "제목, 본문, 여행지 구분, 지역, 여행 성향을 모두 입력해 주세요.");
			return true;   // posts/write.jsp로 다시 forward
		}

		//에디터가 보낸 HTML은 저장 전에 반드시 한 번 걸러야 한다 (HtmlSanitizer 클래스 설명 참고).
		String cleanContent = HtmlSanitizer.clean(content);
		String imgPath = thumbnailFromContent(cleanContent, request.getContextPath(), country);

		PostDTO dto = new PostDTO();
		dto.setWriter(loginMember.getId());   // 화면 값이 아니라 세션의 로그인 id!
		dto.setTitle(title.trim());
		dto.setContent(cleanContent);
		dto.setCountry(country);
		dto.setRegion(regionRequired ? region : null);   // ETC는 지역 구분이 없으니 저장하지 않는다
		dto.setStyle(style);
		dto.setImgPath(imgPath);

		int bno = new PostDAO().insert(dto);

		if (bno == 0) {
			request.setAttribute("msg", "게시글 등록에 실패했습니다.");
			return true;
		}

		new PostLogDAO().insert("CREATE", bno, dto.getTitle(), loginMember.getId());

		response.sendRedirect(request.getContextPath() + "/post/view?bno=" + bno);
		return false;
	}

	private boolean isBlank(String s) {
		return s == null || s.trim().isEmpty();
	}

}
