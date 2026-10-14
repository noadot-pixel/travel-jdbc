package service;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.NoticeDAO;

/**
 * 공지사항 관리 목록(GET /admin/notices). 관리자만 접근 가능 (AdminController에서 검사).
 */
public class NoticeListCommand implements Command {

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		request.setAttribute("noticeList", new NoticeDAO().getList());

		return true;   // admin/notices.jsp로 forward
	}

}
