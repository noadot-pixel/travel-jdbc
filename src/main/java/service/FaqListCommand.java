package service;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.FaqDAO;

/**
 * FAQ 관리 목록(GET /admin/faqs). 관리자만 접근 가능 (AdminController에서 검사).
 */
public class FaqListCommand implements Command {

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		request.setAttribute("faqList", new FaqDAO().getList());

		return true;   // admin/faqs.jsp로 forward
	}

}
