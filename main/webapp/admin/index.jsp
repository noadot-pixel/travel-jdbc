<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%@ page import="model.MemberDTO" %>

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

    long adminIndexJsVer = new java.io.File(application.getRealPath("/js/admin/index.js")).lastModified();
%>

<!DOCTYPE html>
<html lang="ko" <%= (loginMember != null && loginMember.isDarkMode()) ? "data-theme=\"dark\"" : "" %>>

<head>
    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>관리자 - 여행만들기</title>

    <%@ include file="/common/css-links.jspf" %>
</head>

<body>

<% String activeNav = ""; %>
<%@ include file="/common/header.jsp" %>

<main>

    <section class="page-heading">

        <p class="breadcrumb">
            <a href="<%= contextPath %>/main" data-i18n="nav.home">홈</a>
            〉 <span data-i18n="nav.admin">관리자</span>
        </p>

        <h1 data-i18n="nav.admin">관리자</h1>

        <p class="page-description" data-i18n="admin.pageDesc">
            게시글 로그를 확인하고, 예시 게시글을 추가할 수 있습니다.
        </p>

    </section>

    <section class="admin-menu-section">

        <a href="<%= contextPath %>/admin/postLogs"
           class="admin-menu-card">

            <h2 data-i18n="admin.menuLogsTitle">게시글 로그</h2>

            <p data-i18n="admin.menuLogsDesc">
                게시글 작성·수정·삭제 이력을 조회합니다.
            </p>

        </a>

        <a href="<%= contextPath %>/admin/notices"
           class="admin-menu-card">

            <h2 data-i18n="admin.menuNoticesTitle">공지사항 관리</h2>

            <p data-i18n="admin.menuNoticesDesc">
                공지를 등록/삭제합니다. 등록한 공지는 모든 회원의 알림 벨과 공지사항 페이지에 표시됩니다.
            </p>

        </a>

        <a href="<%= contextPath %>/admin/faqs"
           class="admin-menu-card">

            <h2 data-i18n="admin.menuFaqsTitle">FAQ 관리</h2>

            <p data-i18n="admin.menuFaqsDesc">
                자주 묻는 질문을 등록/수정/삭제합니다. 문의하기 페이지 상단에 표시됩니다.
            </p>

        </a>

        <a href="<%= contextPath %>/admin/members"
           class="admin-menu-card">

            <h2 data-i18n="admin.menuMembersTitle">회원 관리</h2>

            <p data-i18n="admin.menuMembersDesc">
                전체 회원 목록을 확인하고, 계정의 활동(댓글/좋아요/글쓰기)을 정지/해제합니다.
            </p>

        </a>

    </section>

    <!-- =========================
         예시 게시글 시드
         posts 테이블이 비어 있을 때만 9개의 예시 게시글을 채워 넣는다.
    ========================== -->

    <section class="admin-seed-section">

        <p class="admin-seed-description" data-i18n="admin.seedDesc">
            게시판이 비어 있을 때 예시 게시글 9개를 한 번에 채워 넣습니다.
            이미 게시글이 있으면 아무 것도 바뀌지 않습니다.
        </p>

        <button type="button"
                id="seedButton"
                class="auth-submit admin-seed-button"
                data-i18n="admin.seedButton">
            예시 게시글 시드 추가
        </button>

    </section>

</main>

<%@ include file="/common/footer.jsp" %>

<script src="<%= contextPath %>/js/admin/index.js?v=<%= adminIndexJsVer %>"></script>

</body>
</html>
