package service;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.InquiryCommentDAO;
import model.InquiryDAO;
import model.InquiryDTO;
import model.MemberDAO;
import model.MemberDTO;
import model.NotificationDAO;
import util.ParamUtil;

/**
 * 문의 댓글 등록(POST /support/comment/write). 일반 게시글 댓글과 달리 누구나 달 수 있는
 * 게 아니라, 그 문의의 작성자 본인과 moderator 이상만 남길 수 있다 - 둘 다 아니면 아무것도
 * 쓰지 않고 그대로 돌려보낸다(화면에 폼 자체가 안 보이므로, 여기 도달하는 건 정상 경로를
 * 벗어난 경우뿐).
 *
 * 알림: 문의 당사자와 moderator 두 "편"만 댓글을 달 수 있으므로, 새 댓글은 항상 반대편에게
 * 알린다 - moderator가 쓰면 문의 작성자 한 명에게, 작성자가 쓰면(후속 질문 등) 모든
 * moderator에게(담당자가 따로 지정되는 구조가 아니라서 전체에게 알리는 게 맞다).
 */
public class InquiryCommentWriteCommand implements Command {

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		int inquiryId = ParamUtil.toInt(request.getParameter("inquiryId"), 0);
		String viewUrl = request.getContextPath() + "/support/view?inquiryId=" + inquiryId;

		MemberDTO loginMember = (MemberDTO) request.getSession().getAttribute("loginMember");

		if (loginMember == null) {
			response.sendRedirect(request.getContextPath() + "/member/login");
			return false;
		}

		InquiryDTO inquiry = new InquiryDAO().getById(inquiryId);

		if (inquiry == null) {
			response.sendRedirect(request.getContextPath() + "/support#contact");
			return false;
		}

		boolean isOwner = loginMember.getId().equals(inquiry.getWriter());

		if (!isOwner && !loginMember.isModerator()) {
			response.sendRedirect(viewUrl);
			return false;
		}

		String content = request.getParameter("content");

		if (content != null && !content.trim().isEmpty()) {

			new InquiryCommentDAO().insert(inquiryId, loginMember.getId(), content.trim());

			NotificationDAO notificationDAO = new NotificationDAO();

			if (isOwner) {
				//작성자가 썼으면(후속 질문 등) moderator 전체에게 알린다 - 담당자가 따로
				//정해지는 구조가 아니라서, "누군가"가 아니라 "전체"에게 맞다.
				for (MemberDTO member : new MemberDAO().getAllMembers()) {
					if (member.isModerator()) {
						notificationDAO.insertForInquiry(member.getId(), inquiryId, loginMember.getId());
					}
				}
			} else {
				//moderator가 썼으면 문의 작성자 한 명에게만 알린다.
				notificationDAO.insertForInquiry(inquiry.getWriter(), inquiryId, loginMember.getId());
			}
		}

		response.sendRedirect(viewUrl);
		return false;
	}

}
