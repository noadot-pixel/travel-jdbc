package model;

/**
 * 문의 상세 페이지의 댓글 한 건. INQUIRY_COMMENTS 테이블 한 행 + 작성자 닉네임(JOIN)에 대응한다.
 */
public class InquiryCommentDTO {

	private int inquiryCommentId;
	private int inquiryId;
	private String writer;
	private String writerNick;
	private String content;
	private String regDate;

	public int getInquiryCommentId() {
		return inquiryCommentId;
	}
	public void setInquiryCommentId(int inquiryCommentId) {
		this.inquiryCommentId = inquiryCommentId;
	}
	public int getInquiryId() {
		return inquiryId;
	}
	public void setInquiryId(int inquiryId) {
		this.inquiryId = inquiryId;
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
	public String getContent() {
		return content;
	}
	public void setContent(String content) {
		this.content = content;
	}
	public String getRegDate() {
		return regDate;
	}
	public void setRegDate(String regDate) {
		this.regDate = regDate;
	}

}
