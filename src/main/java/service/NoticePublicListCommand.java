package service;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.NoticeDAO;

/**
 * 공지사항 목록(GET /notice/list). 로그인 없이 누구나 볼 수 있다 (푸터 "공지사항" 링크).
 */
public class NoticePublicListCommand implements Command {

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		request.setAttribute("noticeList", new NoticeDAO().getList());

		return true;   // notice/list.jsp로 forward
	}

}
