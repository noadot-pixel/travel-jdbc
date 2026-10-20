package model;

/**
 * 회원 한 명. MEMBERS 테이블 한 행에 대응한다.
 * 로그인 성공 시 전체 컬럼을 채워 세션(loginMember)에 저장해두고,
 * 이후 화면에서는 DB를 다시 조회하지 않고 세션의 이 객체를 그대로 쓴다.
 *
 * id = 로그인 아이디(기본키). 기존 Firebase 버전이 이메일/비밀번호로 로그인했던 것과
 * 화면을 그대로 재사용하기 위해, 가입/로그인 화면의 "이메일" 입력값을 그대로 이 id로 쓴다
 * (별도의 "아이디" 입력칸을 추가하지 않음). 그래서 이메일 컬럼을 따로 두지 않는다.
 */
public class MemberDTO {

	private String id;             // 로그인 아이디 = 이메일
	private String pwd;
	private String nickname;
	private int adminLevel;        // ADMIN_LEVEL: 0=일반회원, 1=moderator, 2=admin
	private String joinDate;       // "YYYY-MM-DD"

	private String bio;
	private String country;        // KR / JP / ETC
	private String countryOther;   // country가 ETC일 때 직접 입력값
	private String realName;
	private boolean namePublic;
	private String photoPath;      // 업로드 경로 ("upload/xxx.jpg"), 없으면 null
	private String gender;         // M / F. 이 기능 이전 가입자는 null
	private boolean genderPublic;
	private boolean suspended;     // 관리자가 활동 정지시킨 계정인지 (댓글/좋아요/글쓰기 금지, 스크랩은 허용)
	private boolean darkMode;      // 마이페이지에서 본인이 켜고 끄는 다크모드 선호

	public String getId() {
		return id;
	}
	public void setId(String id) {
		this.id = id;
	}
	public String getPwd() {
		return pwd;
	}
	public void setPwd(String pwd) {
		this.pwd = pwd;
	}
	public String getNickname() {
		return nickname;
	}
	public void setNickname(String nickname) {
		this.nickname = nickname;
	}
	public int getAdminLevel() {
		return adminLevel;
	}
	public void setAdminLevel(int adminLevel) {
		this.adminLevel = adminLevel;
	}
	//관리자 화면에 들어올 수 있는지(모더레이터 이상) - 공지/FAQ/회원 정지/게시글·댓글 관리 등
	//권한 지정을 제외한 거의 모든 관리 기능에서 이 기준을 쓴다.
	public boolean isModerator() {
		return adminLevel >= 1;
	}
	//최상위 관리자인지 - 다른 사람의 권한 레벨을 바꿀 수 있는 건 이 레벨뿐이다.
	public boolean isAdmin() {
		return adminLevel >= 2;
	}
	public String getJoinDate() {
		return joinDate;
	}
	public void setJoinDate(String joinDate) {
		this.joinDate = joinDate;
	}
	public String getBio() {
		return bio;
	}
	public void setBio(String bio) {
		this.bio = bio;
	}
	public String getCountry() {
		return country;
	}
	public void setCountry(String country) {
		this.country = country;
	}
	public String getCountryOther() {
		return countryOther;
	}
	public void setCountryOther(String countryOther) {
		this.countryOther = countryOther;
	}
	public String getRealName() {
		return realName;
	}
	public void setRealName(String realName) {
		this.realName = realName;
	}
	public boolean isNamePublic() {
		return namePublic;
	}
	public void setNamePublic(boolean namePublic) {
		this.namePublic = namePublic;
	}
	public String getPhotoPath() {
		return photoPath;
	}
	public void setPhotoPath(String photoPath) {
		this.photoPath = photoPath;
	}
	public String getGender() {
		return gender;
	}
	public void setGender(String gender) {
		this.gender = gender;
	}
	public boolean isGenderPublic() {
		return genderPublic;
	}
	public void setGenderPublic(boolean genderPublic) {
		this.genderPublic = genderPublic;
	}
	public boolean isSuspended() {
		return suspended;
	}
	public void setSuspended(boolean suspended) {
		this.suspended = suspended;
	}
	public boolean isDarkMode() {
		return darkMode;
	}
	public void setDarkMode(boolean darkMode) {
		this.darkMode = darkMode;
	}

	//성별 코드를 화면에 보여줄 이름으로 바꿔준다 (이 기능 이전 가입자는 gender가 null이라 그대로 null 반환)
	public String getGenderLabel() {
		if ("M".equals(gender)) return "남성";
		if ("F".equals(gender)) return "여성";
		return null;
	}

}
