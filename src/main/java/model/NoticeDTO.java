package model;

/**
 * 공지사항 한 건. NOTICES 테이블 한 행 + 작성한 관리자 닉네임(JOIN)에 대응한다.
 */
public class NoticeDTO {

	private int noticeId;
	private String title;
	private String content;
	private String writer;       // MEMBERS.ID (작성한 관리자)
	private String writerNick;
	private String regDate;      // "YYYY-MM-DD HH24:MI"

	public int getNoticeId() {
		return noticeId;
	}
	public void setNoticeId(int noticeId) {
		this.noticeId = noticeId;
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
	public String getRegDate() {
		return regDate;
	}
	public void setRegDate(String regDate) {
		this.regDate = regDate;
	}

}
