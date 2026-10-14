package service;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.FaqDAO;
import model.InquiryDAO;

/**
 * 자주 묻는 질문 + 문의하기(GET /support). 로그인 없이 누구나 볼 수 있다
 * (글 작성은 InquiryWriteCommand에서 로그인 여부를 따로 검사).
 */
public class SupportPageCommand implements Command {

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		request.setAttribute("faqList", new FaqDAO().getList());
		request.setAttribute("inquiryList", new InquiryDAO().getList());

		return true;   // support.jsp로 forward
	}

}
