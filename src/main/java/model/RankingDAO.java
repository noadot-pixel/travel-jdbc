package model;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import util.DBUtil;

/**
 * 게시글 랭킹 화면 전용 DAO.
 * 국가(KR/JP) x 작성자 성별(M/F) 기준으로, 세부 지역마다 게시글이 몇 개인지 세어
 * 많은 순으로 돌려준다. region이 비어있는 글(이 기능 이전에 쓴 글)은 집계에서 뺀다.
 */
public class RankingDAO {

	public List<RegionRankDTO> getRegionRanking(String country, String gender) {

		String sql = "select p.region, count(*) cnt "
				   + "from posts p join members m on p.writer = m.id "
				   + "where p.country = ? and m.gender = ? and p.region is not null "
				   + "group by p.region "
				   + "order by cnt desc";

		List<RegionRankDTO> list = new ArrayList<RegionRankDTO>();

		try (Connection conn = DBUtil.getInstance();
			 PreparedStatement pstmt = conn.prepareStatement(sql)) {

			pstmt.setString(1, country);
			pstmt.setString(2, gender);

			try (ResultSet rs = pstmt.executeQuery()) {
				while (rs.next()) {
					RegionRankDTO dto = new RegionRankDTO();
					dto.setRegion(rs.getString("region"));
					dto.setPostCount(rs.getInt("cnt"));
					list.add(dto);
				}
			}

		} catch (Exception e) {
			System.out.println(e.getMessage());
		}

		return list;
	}

}
