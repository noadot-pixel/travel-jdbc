package service;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * 아무 조회/처리도 필요 없이 그냥 화면으로 forward만 하면 되는 라우트용
 * (예: auth/privacy.jsp처럼 완전히 정적인 페이지).
 */
public class NoOpCommand implements Command {

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		return true;
	}

}
