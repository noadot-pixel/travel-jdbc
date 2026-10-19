package model;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import util.DBUtil;

/**
 * 게시글 랭킹 화면 전용 DAO.
 * 국가(KR/JP) x 작성자 성별(M/F) 기준으로, 세부 지역마다 게시글이 몇 개인지 세어
 * 많은 순으로 돌려준다. region이 비어있는 글(이 기능 이전에 쓴 글)은 집계에서 뺀다.
 * 게시글이 하나도 없는 지역도 0개로 목록에 포함시킨다(PostDTO.regionsForCountry 기준).
 */
public class RankingDAO {

	public List<RegionRankDTO> getRegionRanking(String country, String gender) {

		String sql = "select p.region, count(*) cnt "
				   + "from posts p join members m on p.writer = m.id "
				   + "where p.country = ? and m.gender = ? and p.region is not null "
				   + "group by p.region";

		Map<String, Integer> counts = new HashMap<String, Integer>();

		try (Connection conn = DBUtil.getInstance();
			 PreparedStatement pstmt = conn.prepareStatement(sql)) {

			pstmt.setString(1, country);
			pstmt.setString(2, gender);

			try (ResultSet rs = pstmt.executeQuery()) {
				while (rs.next()) {
					counts.put(rs.getString("region"), rs.getInt("cnt"));
				}
			}

		} catch (Exception e) {
			System.out.println(e.getMessage());
		}

		return toFullRegionList(country, counts);
	}

	//지도 색칠용 - 성별 구분 없이(성별 미입력 회원 포함) 지역별 전체 게시글 수
	public List<RegionRankDTO> getRegionRankingTotal(String country) {

		String sql = "select p.region, count(*) cnt "
				   + "from posts p "
				   + "where p.country = ? and p.region is not null "
				   + "group by p.region";

		Map<String, Integer> counts = new HashMap<String, Integer>();

		try (Connection conn = DBUtil.getInstance();
			 PreparedStatement pstmt = conn.prepareStatement(sql)) {

			pstmt.setString(1, country);

			try (ResultSet rs = pstmt.executeQuery()) {
				while (rs.next()) {
					counts.put(rs.getString("region"), rs.getInt("cnt"));
				}
			}

		} catch (Exception e) {
			System.out.println(e.getMessage());
		}

		return toFullRegionList(country, counts);
	}

	//region->count 집계 결과를, 국가의 전체 지역 목록(0개 지역 포함) 기준으로 채워서
	//게시글 수 내림차순으로 정렬한다. 0개끼리는 regionsForCountry에 적어둔 순서를 유지한다.
	private List<RegionRankDTO> toFullRegionList(String country, Map<String, Integer> counts) {

		String[] regions = PostDTO.regionsForCountry(country);
		List<RegionRankDTO> list = new ArrayList<RegionRankDTO>();

		for (String region : regions) {
			RegionRankDTO dto = new RegionRankDTO();
			dto.setRegion(region);
			dto.setPostCount(counts.containsKey(region) ? counts.get(region) : 0);
			list.add(dto);
		}

		list.sort(new Comparator<RegionRankDTO>() {
			@Override
			public int compare(RegionRankDTO a, RegionRankDTO b) {
				return Integer.compare(b.getPostCount(), a.getPostCount());
			}
		});

		return list;
	}

}
