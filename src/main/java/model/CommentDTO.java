package model;

/**
 * 댓글 한 건. COMMENTS 테이블 한 행 + 작성자 닉네임에 대응한다.
 */
public class CommentDTO {

	private int cno;
	private int bno;            // 어느 게시글의 댓글인지
	private String writer;      // MEMBERS.ID
	private String writerNick;
	private String content;
	private String regDate;     // "YYYY-MM-DD HH24:MI"
	private String postTitle;   // 마이페이지 "내가 쓴 댓글" 목록에서만 채워짐 (어느 글의 댓글인지 보여주려고)

	public int getCno() {
		return cno;
	}
	public void setCno(int cno) {
		this.cno = cno;
	}
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
	public String getPostTitle() {
		return postTitle;
	}
	public void setPostTitle(String postTitle) {
		this.postTitle = postTitle;
	}

}
