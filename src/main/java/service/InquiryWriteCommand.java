package service;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.InquiryDAO;
import model.MemberDTO;

/**
 * 문의 글 등록(POST /support/write). 로그인한 회원만 쓸 수 있다
 * (로그인 여부는 SupportController에서 미리 확인).
 */
public class InquiryWriteCommand implements Command {

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		MemberDTO loginMember = (MemberDTO) request.getSession().getAttribute("loginMember");

		String title = request.getParameter("title");
		String content = request.getParameter("content");

		if (title == null || title.trim().isEmpty() || content == null || content.trim().isEmpty()) {
			request.setAttribute("msg", "제목과 내용을 모두 입력해 주세요.");
			request.setAttribute("faqList", new model.FaqDAO().getList());
			request.setAttribute("inquiryList", new InquiryDAO().getList());
			return true;   // support.jsp로 다시 forward
		}

		new InquiryDAO().insert(title.trim(), content.trim(), loginMember.getId());

		//새로고침해도 문의가 두 번 등록되지 않도록 redirect. #contact로 돌아가 방금 올린 글을 바로 본다.
		response.sendRedirect(request.getContextPath() + "/support#contact");
		return false;
	}

}
