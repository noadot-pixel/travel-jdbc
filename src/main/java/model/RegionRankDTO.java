package model;

/**
 * 랭킹 화면 한 줄 - 특정 국가(KR/JP)의 세부 지역 하나와, 그 지역의 게시글 개수.
 */
public class RegionRankDTO {

	private String region;
	private int postCount;

	public String getRegion() {
		return region;
	}
	public void setRegion(String region) {
		this.region = region;
	}
	public int getPostCount() {
		return postCount;
	}
	public void setPostCount(int postCount) {
		this.postCount = postCount;
	}

	//지역 코드를 화면에 보여줄 이름으로 바꿔준다 (PostDTO와 같은 매핑을 재사용)
	public String getRegionLabel() {
		return PostDTO.labelForRegion(region);
	}

}
