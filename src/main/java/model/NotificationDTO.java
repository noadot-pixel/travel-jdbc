package model;

/**
 * 개인 알림 한 건 (내 글에 달린 댓글/좋아요, 또는 내가 관련된 문의에 달린 댓글).
 * NOTIFICATIONS 테이블 한 행 + 행동한 회원 닉네임, 대상(게시글 또는 문의) 제목(둘 다 JOIN)에 대응한다.
 * targetType이 "POST"면 bno/postTitle이, "INQUIRY"면 inquiryId/inquiryTitle이 채워진다.
 */
public class NotificationDTO {

	private int notifId;
	private String type;        // COMMENT / LIKE / INQUIRY_COMMENT
	private String targetType;  // POST / INQUIRY
	private int bno;
	private String postTitle;
	private int inquiryId;
	private String inquiryTitle;
	private String actorId;
	private String actorNick;
	private boolean read;
	private String regDate;     // "YYYY-MM-DD HH24:MI"

	public int getNotifId() {
		return notifId;
	}
	public void setNotifId(int notifId) {
		this.notifId = notifId;
	}
	public String getType() {
		return type;
	}
	public void setType(String type) {
		this.type = type;
	}
	public String getTargetType() {
		return targetType;
	}
	public void setTargetType(String targetType) {
		this.targetType = targetType;
	}
	public int getBno() {
		return bno;
	}
	public void setBno(int bno) {
		this.bno = bno;
	}
	public String getPostTitle() {
		return postTitle;
	}
	public void setPostTitle(String postTitle) {
		this.postTitle = postTitle;
	}
	public int getInquiryId() {
		return inquiryId;
	}
	public void setInquiryId(int inquiryId) {
		this.inquiryId = inquiryId;
	}
	public String getInquiryTitle() {
		return inquiryTitle;
	}
	public void setInquiryTitle(String inquiryTitle) {
		this.inquiryTitle = inquiryTitle;
	}
	public String getActorId() {
		return actorId;
	}
	public void setActorId(String actorId) {
		this.actorId = actorId;
	}
	public String getActorNick() {
		return actorNick;
	}
	public void setActorNick(String actorNick) {
		this.actorNick = actorNick;
	}
	public boolean isRead() {
		return read;
	}
	public void setRead(boolean read) {
		this.read = read;
	}
	public String getRegDate() {
		return regDate;
	}
	public void setRegDate(String regDate) {
		this.regDate = regDate;
	}

	//화면에 보여줄 한 줄 메시지
	public String getMessage() {
		if ("LIKE".equals(type)) {
			return actorNick + "님이 내 글을 좋아합니다 - " + postTitle;
		}
		if ("INQUIRY_COMMENT".equals(type)) {
			return actorNick + "님이 문의에 댓글을 남겼습니다 - " + inquiryTitle;
		}
		return actorNick + "님이 내 글에 댓글을 남겼습니다 - " + postTitle;   // COMMENT (기본값)
	}

}
