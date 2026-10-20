package model;

/**
 * 문의 글 한 건. INQUIRIES 테이블 한 행 + 작성자 닉네임(JOIN)에 대응한다.
 * 답변은 댓글(INQUIRY_COMMENTS, InquiryCommentDTO)로 처리하므로 여기엔 없다.
 */
public class InquiryDTO {

	private int inquiryId;
	private String title;
	private String content;
	private String writer;
	private String writerNick;
	private String regDate;
	private boolean isPrivate;

	public int getInquiryId() {
		return inquiryId;
	}
	public void setInquiryId(int inquiryId) {
		this.inquiryId = inquiryId;
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
	public boolean isPrivate() {
		return isPrivate;
	}
	public void setPrivate(boolean isPrivate) {
		this.isPrivate = isPrivate;
	}

}
