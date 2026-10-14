<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%@ page import="java.util.List" %>
<%@ page import="model.NoticeDTO" %>
<%@ page import="util.EscapeUtil" %>

<%
    String contextPath = request.getContextPath();

    //이 페이지는 반드시 NoticeController(/notice/list)를 거쳐서 와야 한다.
    List<NoticeDTO> noticeList = (List<NoticeDTO>) request.getAttribute("noticeList");

    if (noticeList == null) {
        response.sendRedirect(contextPath + "/notice/list");
        return;
    }
%>

<!DOCTYPE html>
<html lang="ko">

<head>
    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>공지사항 - 여행만들기</title>

    <%@ include file="/common/css-links.jspf" %>
</head>

<body>

<% String activeNav = ""; %>
<%@ include file="/common/header.jsp" %>

<main>

    <section class="page-heading">

        <p class="breadcrumb">
            <a href="<%= contextPath %>/main">홈</a>
            〉 공지사항
        </p>

        <h1>공지사항</h1>

        <p class="page-description">
            여행만들기의 새 소식을 확인하세요.
        </p>

    </section>

    <section class="notice-list-section">

        <% if (noticeList.isEmpty()) { %>
        <p class="ranking-empty">등록된 공지가 없습니다.</p>
        <% } else { %>
        <ul class="notice-list">
            <% for (NoticeDTO notice : noticeList) { %>
            <li class="notice-item">

                <div class="notice-item-head">
                    <strong>
                        <a href="<%= contextPath %>/notice/view?noticeId=<%= notice.getNoticeId() %>">
                            <%= EscapeUtil.html(notice.getTitle()) %>
                        </a>
                    </strong>
                    <span><%= notice.getRegDate() %> · <%= EscapeUtil.html(notice.getWriterNick()) %></span>
                </div>

            </li>
            <% } %>
        </ul>
        <% } %>

    </section>

</main>

<%@ include file="/common/footer.jsp" %>

</body>
</html>
