package service;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.InquiryCommentDAO;
import model.InquiryDAO;
import model.InquiryDTO;
import model.MemberDTO;
import util.ParamUtil;

/**
 * 문의 상세보기(GET /support/view). 비공개 글은 작성자 본인이거나 moderator 이상이어야
 * 볼 수 있다 - 그 외는 목록으로 돌려보낸다(없는 글/권한 없음을 굳이 구분해서 알려줄 필요는 없음).
 * 댓글(답변)은 그 문의의 작성자 본인과 moderator 이상만 남길 수 있어서, 화면이 댓글 폼을
 * 보여줄지 결정할 수 있도록 canComment를 같이 내려준다.
 */
public class InquiryViewCommand implements Command {

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		int inquiryId = ParamUtil.toInt(request.getParameter("inquiryId"), 0);
		InquiryDTO inquiry = new InquiryDAO().getById(inquiryId);

		if (inquiry == null) {
			response.sendRedirect(request.getContextPath() + "/support#contact");
			return false;
		}

		MemberDTO loginMember = (MemberDTO) request.getSession().getAttribute("loginMember");
		boolean isModerator = loginMember != null && loginMember.isModerator();
		boolean isOwner = loginMember != null && loginMember.getId().equals(inquiry.getWriter());

		if (inquiry.isPrivate() && !isOwner && !isModerator) {
			response.sendRedirect(request.getContextPath() + "/support#contact");
			return false;
		}

		request.setAttribute("inquiry", inquiry);
		request.setAttribute("commentList", new InquiryCommentDAO().getList(inquiryId));
		request.setAttribute("canComment", isOwner || isModerator);
		return true;   // support/view.jsp로 forward
	}

}
