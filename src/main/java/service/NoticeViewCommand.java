package service;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.NoticeDAO;
import model.NoticeDTO;
import util.ParamUtil;

/**
 * 공지사항 상세(GET /notice/view?noticeId=). 로그인 없이 누구나 볼 수 있다.
 */
public class NoticeViewCommand implements Command {

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		int noticeId = ParamUtil.toInt(request.getParameter("noticeId"), 0);
		NoticeDTO notice = new NoticeDAO().getById(noticeId);

		if (notice == null) {
			response.sendRedirect(request.getContextPath() + "/notice/list");
			return false;
		}

		request.setAttribute("notice", notice);

		return true;   // notice/view.jsp로 forward
	}

}
