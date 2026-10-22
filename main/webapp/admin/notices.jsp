<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%@ page import="java.util.List" %>
<%@ page import="model.MemberDTO" %>
<%@ page import="model.NoticeDTO" %>
<%@ page import="util.EscapeUtil" %>

<%
    String contextPath = request.getContextPath();

    MemberDTO loginMember = (MemberDTO) session.getAttribute("loginMember");

    if (loginMember == null) {
        response.sendRedirect(contextPath + "/member/login");
        return;
    }

    if (!loginMember.isModerator()) {
        response.sendRedirect(contextPath + "/main");
        return;
    }

    //이 페이지는 반드시 NoticeListCommand(/admin/notices)를 거쳐서 와야 한다.
    List<NoticeDTO> noticeList = (List<NoticeDTO>) request.getAttribute("noticeList");

    if (noticeList == null) {
        response.sendRedirect(contextPath + "/admin/notices");
        return;
    }

    long adminNoticesJsVer = new java.io.File(application.getRealPath("/js/admin/notices.js")).lastModified();
%>

<!DOCTYPE html>
<html lang="ko" <%= (loginMember != null && loginMember.isDarkMode()) ? "data-theme=\"dark\"" : "" %>>

<head>
    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title data-i18n="title.adminNotices">공지사항 관리 - 여행만들기</title>

    <%@ include file="/common/css-links.jspf" %>
</head>

<body class="composer-page composer-notices">

<% String activeNav = ""; %>
<%@ include file="/common/header.jsp" %>

<main class="composer-page-main">

    <section class="page-heading">

        <p class="breadcrumb">
            <a href="<%= contextPath %>/main" data-i18n="nav.home">홈</a>
            〉 <a href="<%= contextPath %>/admin" data-i18n="nav.admin">관리자</a>
            〉 <span data-i18n="admin.menuNoticesTitle">공지사항 관리</span>
        </p>

        <h1 data-i18n="admin.menuNoticesTitle">공지사항 관리</h1>

        <p class="page-description" data-i18n="adminNotices.pageDesc">
            등록한 공지는 모든 회원의 알림 벨에 표시됩니다.
        </p>

    </section>

    <section class="write-section">

        <form id="noticeForm">

            <div class="composer-paper">

                <div class="composer-section-heading">
                    <span class="composer-step">01</span>
                    <h2 data-i18n="admin.menuNoticesTitle">공지사항 관리</h2>
                </div>

                <div class="write-field">
                    <label for="noticeTitle" data-i18n="write.titleLabel">제목</label>
                    <input type="text" id="noticeTitle" data-i18n="adminNotices.titlePlaceholder" data-i18n-attr="placeholder" placeholder="공지 제목을 입력해 주세요">
                </div>

                <div class="write-field">
                    <label for="noticeContentEditor" data-i18n="support.contentLabel">내용</label>
                    <div id="noticeContentEditor" class="quill-editor-container"></div>
                    <input type="hidden" id="noticeContent" name="content">
                </div>

            </div>

            <div class="composer-actions">
                <span data-i18n="editor.publishHint">작성한 내용을 확인한 뒤 등록해 주세요.</span>
                <button type="submit" class="auth-submit" data-i18n="write.submit">등록하기</button>
            </div>

        </form>

    </section>

    <section class="admin-notice-list-section">

        <% if (noticeList.isEmpty()) { %>
        <p class="ranking-empty" data-i18n="notice.empty">등록된 공지가 없습니다.</p>
        <% } else { %>
        <ul class="admin-notice-list">
            <% for (NoticeDTO notice : noticeList) { %>
            <li class="admin-notice-item" data-notice-id="<%= notice.getNoticeId() %>">

                <div class="admin-notice-item-head">
                    <strong><%= EscapeUtil.html(notice.getTitle()) %></strong>
                    <span><%= notice.getRegDate() %> · <%= EscapeUtil.html(notice.getWriterNick()) %></span>
                </div>

                <div class="detail-body admin-notice-content"><%= notice.getContent() %></div>

                <button type="button" class="admin-notice-delete-button" data-notice-id="<%= notice.getNoticeId() %>" data-i18n="common.delete">삭제</button>

            </li>
            <% } %>
        </ul>
        <% } %>

    </section>

</main>

<%@ include file="/common/footer.jsp" %>
<%@ include file="/common/quill-assets.jspf" %>

<script src="<%= contextPath %>/js/admin/notices.js?v=<%= adminNoticesJsVer %>"></script>

</body>
</html>
