<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%@ page import="model.MemberDTO" %>
<%@ page import="model.NoticeDTO" %>
<%@ page import="util.EscapeUtil" %>

<%
    String contextPath = request.getContextPath();

    MemberDTO themeMember = (MemberDTO) session.getAttribute("loginMember");

    //이 페이지는 반드시 NoticeViewCommand(/notice/view)를 거쳐서 와야 한다.
    NoticeDTO notice = (NoticeDTO) request.getAttribute("notice");

    if (notice == null) {
        response.sendRedirect(contextPath + "/notice/list");
        return;
    }
%>

<!DOCTYPE html>
<html lang="ko" <%= (themeMember != null && themeMember.isDarkMode()) ? "data-theme=\"dark\"" : "" %>>

<head>
    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title><%= EscapeUtil.html(notice.getTitle()) %> - 여행만들기</title>

    <%@ include file="/common/css-links.jspf" %>
</head>

<body>

<% String activeNav = ""; %>
<%@ include file="/common/header.jsp" %>

<main>

    <section class="page-heading">

        <p class="breadcrumb">
            <a href="<%= contextPath %>/main" data-i18n="nav.home">홈</a>
            〉 <a href="<%= contextPath %>/notice/list" data-i18n="footer.notices">공지사항</a>
            〉 <span data-i18n="detail.breadcrumb">상세</span>
        </p>

    </section>

    <section class="detail-section">

        <div class="detail-header">

            <h1><%= EscapeUtil.html(notice.getTitle()) %></h1>

            <div class="story-information">
                <span><%= EscapeUtil.html(notice.getWriterNick()) %></span>
                <span><%= notice.getRegDate() %></span>
            </div>

        </div>

        <%-- notice.getContent()는 등록 시 HtmlSanitizer로 걸러낸 HTML이라 그대로 출력해도 안전하다. --%>
        <div class="detail-body"><%= notice.getContent() %></div>

        <div class="detail-back">
            <a href="<%= contextPath %>/notice/list">
                〈 <span data-i18n="detail.backToList">목록으로</span>
            </a>
        </div>

    </section>

</main>

<%@ include file="/common/footer.jsp" %>

</body>
</html>
