package model;

/**
 * 게시글 한 건. POSTS 테이블 한 행 + 작성자 닉네임(JOIN으로 가져옴)에 대응한다.
 */
public class PostDTO {

	private int bno;
	private String writer;       // MEMBERS.ID (작성자 아이디)
	private String writerNick;   // JOIN으로 가져온 작성자 닉네임 (화면 표시용, POSTS에는 없음)
	private String title;
	private String content;
	private String country;      // KR / JP / ETC
	private String region;       // country=KR/JP일 때만 값 있음(세부 지역). ETC는 null.
	private String style;        // healing / food / activity / shopping
	private String imgPath;      // "images/korea.jpg"(기본) 또는 "upload/xxx.jpg"(업로드)
	private int viewCnt;
	private int likeCnt;
	private int commentCnt;      // COMMENTS 테이블에서 subquery로 세어옴 (POSTS에는 없는 컬럼)
	private String regDate;      // "YYYY-MM-DD"
	private String modDate;      // "YYYY-MM-DD" 또는 null(수정 전)

	public int getBno() {
		return bno;
	}
	public void setBno(int bno) {
		this.bno = bno;
	}
	public String getWriter() {
		return writer;
	}
	public void setWriter(String writer) {
		this.writer = writer;
	}
	public String getWriterNick() {
		return writerNick;
	}
	public void setWriterNick(String writerNick) {
		this.writerNick = writerNick;
	}
	public String getTitle() {
		return title;
	}
	public void setTitle(String title) {
		this.title = title;
	}
	public String getContent() {
		return content;
	}
	public void setContent(String content) {
		this.content = content;
	}
	public String getCountry() {
		return country;
	}
	public void setCountry(String country) {
		this.country = country;
	}
	public String getRegion() {
		return region;
	}
	public void setRegion(String region) {
		this.region = region;
	}
	public String getStyle() {
		return style;
	}
	public void setStyle(String style) {
		this.style = style;
	}
	public String getImgPath() {
		return imgPath;
	}
	public void setImgPath(String imgPath) {
		this.imgPath = imgPath;
	}
	public int getViewCnt() {
		return viewCnt;
	}
	public void setViewCnt(int viewCnt) {
		this.viewCnt = viewCnt;
	}
	public int getLikeCnt() {
		return likeCnt;
	}
	public void setLikeCnt(int likeCnt) {
		this.likeCnt = likeCnt;
	}
	public int getCommentCnt() {
		return commentCnt;
	}
	public void setCommentCnt(int commentCnt) {
		this.commentCnt = commentCnt;
	}
	public String getRegDate() {
		return regDate;
	}
	public void setRegDate(String regDate) {
		this.regDate = regDate;
	}
	public String getModDate() {
		return modDate;
	}
	public void setModDate(String modDate) {
		this.modDate = modDate;
	}

	//국가 코드를 화면에 보여줄 이름으로 바꿔준다 (Firebase 버전의 countryLabel과 같은 값)
	public String getCountryLabel() {
		if ("KR".equals(country)) return "한국 여행지";
		if ("JP".equals(country)) return "일본 여행지";
		if ("ETC".equals(country)) return "세계 여행지";
		return country;
	}

	//여행 성향 코드를 화면에 보여줄 이름으로 바꿔준다
	public String getStyleLabel() {
		if ("healing".equals(style)) return "힐링";
		if ("food".equals(style)) return "맛집";
		if ("activity".equals(style)) return "액티비티";
		if ("shopping".equals(style)) return "쇼핑";
		return style;
	}

	//세부 지역 코드를 화면에 보여줄 이름으로 바꿔준다 (country=ETC면 region 자체가 null)
	public String getRegionLabel() {
		return labelForRegion(region);
	}

	//위와 같은 변환을 랭킹 화면(RegionRankDTO)에서도 써야 해서 static으로 빼둔다.
	public static String labelForRegion(String region) {
		if ("KR_CAPITAL".equals(region)) return "서울·경기·인천";
		if ("KR_GANGWON".equals(region)) return "강원도";
		if ("KR_CHUNGCHEONG".equals(region)) return "충청도";
		if ("KR_JEOLLA".equals(region)) return "전라도";
		if ("KR_GYEONGSANG".equals(region)) return "경상도";
		if ("KR_JEJU".equals(region)) return "제주도";

		if ("JP_HOKKAIDO".equals(region)) return "홋카이도 지방";
		if ("JP_TOHOKU".equals(region)) return "도호쿠 지방";
		if ("JP_KANTO".equals(region)) return "간토 지방";
		if ("JP_CHUBU".equals(region)) return "주부 지방";
		if ("JP_KANSAI".equals(region)) return "긴키·간사이 지방";
		if ("JP_CHUGOKU".equals(region)) return "주고쿠 지방";
		if ("JP_SHIKOKU".equals(region)) return "시코쿠 지방";
		if ("JP_KYUSHU_OKINAWA".equals(region)) return "규슈·오키나와 지방";

		return region;
	}

	//국가별 세부 지역 코드 전체 목록 - 랭킹 화면에서 게시글이 0개인 지역도 빠짐없이 보여주기 위해 사용.
	public static String[] regionsForCountry(String country) {
		if ("JP".equals(country)) {
			return new String[] { "JP_HOKKAIDO", "JP_TOHOKU", "JP_KANTO", "JP_CHUBU",
					"JP_KANSAI", "JP_CHUGOKU", "JP_SHIKOKU", "JP_KYUSHU_OKINAWA" };
		}
		return new String[] { "KR_CAPITAL", "KR_GANGWON", "KR_CHUNGCHEONG",
				"KR_JEOLLA", "KR_GYEONGSANG", "KR_JEJU" };
	}

}
