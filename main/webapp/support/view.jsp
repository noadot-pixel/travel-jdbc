<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%@ page import="java.util.List" %>
<%@ page import="model.InquiryCommentDTO" %>
<%@ page import="model.InquiryDTO" %>
<%@ page import="model.MemberDTO" %>
<%@ page import="util.EscapeUtil" %>

<%
    String contextPath = request.getContextPath();

    MemberDTO loginMember = (MemberDTO) session.getAttribute("loginMember");

    //이 페이지는 반드시 InquiryViewCommand(/support/view)를 거쳐서 와야 한다.
    InquiryDTO inquiry = (InquiryDTO) request.getAttribute("inquiry");
    List<InquiryCommentDTO> commentList = (List<InquiryCommentDTO>) request.getAttribute("commentList");
    Boolean canCommentAttr = (Boolean) request.getAttribute("canComment");

    if (inquiry == null || commentList == null || canCommentAttr == null) {
        response.sendRedirect(contextPath + "/support#contact");
        return;
    }

    boolean canComment = canCommentAttr;
%>

<!DOCTYPE html>
<html lang="ko" <%= (loginMember != null && loginMember.isDarkMode()) ? "data-theme=\"dark\"" : "" %>>

<head>
    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title><%= EscapeUtil.html(inquiry.getTitle()) %> - 여행만들기</title>

    <%@ include file="/common/css-links.jspf" %>
</head>

<body>

<% String activeNav = ""; %>
<%@ include file="/common/header.jsp" %>

<main>

    <section class="page-heading">

        <p class="breadcrumb">
            <a href="<%= contextPath %>/main" data-i18n="nav.home">홈</a>
            〉 <a href="<%= contextPath %>/support#contact" data-i18n="support.contactHeading">문의하기</a>
            〉 <span data-i18n="detail.breadcrumb">상세</span>
        </p>

    </section>

    <section class="detail-section">

        <div class="detail-header">

            <h1><%= EscapeUtil.html(inquiry.getTitle()) %></h1>

            <div class="story-information">
                <% if (inquiry.isPrivate()) { %>
                <span class="inquiry-private-badge" data-i18n="mypage.private">비공개</span>
                <% } %>
                <span><%= EscapeUtil.html(inquiry.getWriterNick()) %></span>
                <span><%= inquiry.getRegDate() %></span>
            </div>

        </div>

        <div class="detail-body inquiry-content-body"><%= EscapeUtil.html(inquiry.getContent()) %></div>

        <section class="comment-section">

            <h2><span data-i18n="support.commentsHeading">문의 댓글</span> <span><%= commentList.size() %></span></h2>

            <% if (canComment) { %>
            <form method="post" action="<%= contextPath %>/support/comment/write" class="comment-form">

                <input type="hidden" name="inquiryId" value="<%= inquiry.getInquiryId() %>">

                <textarea name="content"
                          rows="3"
                          maxlength="1000"
                          data-i18n="support.commentPlaceholder"
                          data-i18n-attr="placeholder"
                          placeholder="댓글을 남겨보세요"></textarea>

                <button type="submit" class="comment-submit" data-i18n="detail.commentSubmit">
                    댓글 등록
                </button>

            </form>
            <% } else if (loginMember == null) { %>
            <p class="comment-empty">
                <a href="<%= contextPath %>/member/login" data-i18n="nav.login">로그인</a> <span data-i18n="support.loginToCommentSuffix">후 문의 당사자나 운영진이면 댓글을 남길 수 있습니다.</span>
            </p>
            <% } else { %>
            <p class="comment-empty" data-i18n="support.commentForbidden">
                문의 작성자와 운영진만 댓글을 남길 수 있습니다.
            </p>
            <% } %>

            <ul class="comment-list">

                <% for (InquiryCommentDTO comment : commentList) { %>
                <li class="comment-item">

                    <div class="comment-head">
                        <strong><%= EscapeUtil.html(comment.getWriterNick()) %></strong>
                        <% if (comment.getWriter().equals(inquiry.getWriter())) { %>
                        <span class="my-post-badge" data-i18n="detail.postAuthor">작성자</span>
                        <% } %>
                        <span class="comment-time"><%= comment.getRegDate() %></span>
                    </div>

                    <p class="comment-body"><%= EscapeUtil.html(comment.getContent()) %></p>

                </li>
                <% } %>

            </ul>

            <% if (commentList.isEmpty()) { %>
            <p class="comment-empty" data-i18n="support.noComments">
                아직 댓글이 없습니다.
            </p>
            <% } %>

        </section>

        <div class="detail-back">
            <a href="<%= contextPath %>/support#contact">
                〈 <span data-i18n="detail.backToList">목록으로</span>
            </a>
        </div>

    </section>

</main>

<%@ include file="/common/footer.jsp" %>

</body>
</html>
