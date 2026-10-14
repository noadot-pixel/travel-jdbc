package service;

import java.io.IOException;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.RankingDAO;
import model.RegionRankDTO;

/**
 * 게시글 랭킹(GET /post/ranking) - 국가(KR/JP) x 성별(M/F)별 인기 지역 순위.
 * 로그인 없이도 볼 수 있는 화면이라 PostController의 needsLogin 대상에는 넣지 않는다.
 */
public class RankingCommand implements Command {

	@Override
	public boolean doCommand(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		String country = request.getParameter("country");

		//KR/JP 둘 중 하나만 받는다. 그 외(없음/ETC/엉뚱한 값)는 기본값 KR로.
		if (!"JP".equals(country)) {
			country = "KR";
		}

		RankingDAO dao = new RankingDAO();
		List<RegionRankDTO> maleRanking = dao.getRegionRanking(country, "M");
		List<RegionRankDTO> femaleRanking = dao.getRegionRanking(country, "F");

		request.setAttribute("country", country);
		request.setAttribute("maleRanking", maleRanking);
		request.setAttribute("femaleRanking", femaleRanking);

		return true;   // posts/ranking.jsp로 forward
	}

}
