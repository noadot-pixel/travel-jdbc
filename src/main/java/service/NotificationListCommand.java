package service;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.MemberDTO;
import model.NoticeDAO;
import model.NoticeDTO;
import model.NotificationDAO;
import model.NotificationDTO;
import org.jsoup.Jsoup;
import util.EscapeUtil;

/**
 * 알림 벨 드롭다운(Ajax, GET /notification/list) - 공지 최신 5개 + 내 개인 알림 최신 10개를
 * JSON으로 돌려주고, 그 자리에서 전부 "읽음" 처리한다(공지는 last_notice_seen 갱신,
 * 개인 알림은 is_read='Y').
 */
public class NotificationListCommand implements Command {

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		response.setContentType("application/json; charset=utf-8");
		PrintWriter out = response.getWriter();

		MemberDTO loginMember = (MemberDTO) request.getSession().getAttribute("loginMember");

		if (loginMember == null) {
			out.print("{\"result\":\"login\"}");
			return false;
		}

		String memberId = loginMember.getId();

		List<NoticeDTO> notices = new NoticeDAO().getRecent(5);
		List<NotificationDTO> alerts = new NotificationDAO().getRecent(memberId, 10);

		StringBuilder json = new StringBuilder();
		json.append("{\"result\":\"ok\",\"notices\":[");

		for (int i = 0; i < notices.size(); i++) {
			NoticeDTO n = notices.get(i);
			if (i > 0) json.append(",");
			//본문은 에디터 HTML이라 벨 미리보기(툴팁)에는 태그를 뺀 글자만 보여준다.
			String contentPreview = Jsoup.parse(n.getContent()).text();
			json.append("{\"noticeId\":").append(n.getNoticeId()).append(",")
				.append("\"title\":\"").append(EscapeUtil.json(n.getTitle())).append("\",")
				.append("\"content\":\"").append(EscapeUtil.json(contentPreview)).append("\",")
				.append("\"regDate\":\"").append(EscapeUtil.json(n.getRegDate())).append("\"}");
		}

		json.append("],\"alerts\":[");

		for (int i = 0; i < alerts.size(); i++) {
			NotificationDTO a = alerts.get(i);
			if (i > 0) json.append(",");
			json.append("{\"bno\":").append(a.getBno()).append(",")
				.append("\"message\":\"").append(EscapeUtil.json(a.getMessage())).append("\",")
				.append("\"read\":").append(a.isRead()).append(",")
				.append("\"regDate\":\"").append(EscapeUtil.json(a.getRegDate())).append("\"}");
		}

		json.append("]}");

		out.print(json.toString());

		//화면에 보여준 시점에 전부 읽음 처리 (다음에 열 때는 배지가 0부터 다시 쌓인다)
		new NoticeDAO().markSeen(memberId);
		new NotificationDAO().markAllRead(memberId);

		return false;
	}

}
