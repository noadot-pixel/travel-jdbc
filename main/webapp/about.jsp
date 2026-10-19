<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%@ page import="model.MemberDTO" %>

<%
    String contextPath = request.getContextPath();

    MemberDTO themeMember = (MemberDTO) session.getAttribute("loginMember");
%>

<!DOCTYPE html>
<html lang="ko" <%= (themeMember != null && themeMember.isDarkMode()) ? "data-theme=\"dark\"" : "" %>>

<head>
    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>소개 - 여행만들기</title>

    <%@ include file="/common/css-links.jspf" %>
</head>

<body>

<% String activeNav = ""; %>
<%@ include file="/common/header.jsp" %>

<main>

    <section class="page-heading">

        <p class="breadcrumb">
            <a href="<%= contextPath %>/main" data-i18n="nav.home">홈</a>
            〉 <span data-i18n="footer.about">소개</span>
        </p>

        <h1 data-i18n="about.heading">여행만들기 소개</h1>

        <p class="page-description" data-i18n="about.pageDesc">
            여행 이야기를 자유롭게 기록하고 나누는 커뮤니티입니다.
        </p>

    </section>

    <section class="write-section policy-content">

        <p data-i18n="about.intro">
            '여행만들기'는 국내·일본·해외 여행 경험을 성향별(힐링/맛집/액티비티/쇼핑)로 기록하고
            나눌 수 있는 커뮤니티입니다.
        </p>

        <h2 data-i18n="about.featuresTitle">이런 걸 할 수 있어요</h2>

        <ul>
            <li data-i18n="about.feature1">여행지(국내/일본/해외)와 세부 지역, 여행 성향을 태그로 남긴 글쓰기</li>
            <li data-i18n="about.feature2">댓글, 좋아요, 스크랩으로 다른 사람의 여행 이야기에 반응하기</li>
            <li><span data-i18n="about.feature3Prefix">성별 · 여행지별 인기 지역을 보여주는</span> <a href="<%= contextPath %>/post/ranking" data-i18n="ranking.title">게시글 랭킹</a></li>
            <li><span data-i18n="about.feature4Prefix">새 소식은 헤더 알림 벨과</span> <a href="<%= contextPath %>/notice/list" data-i18n="footer.notices">공지사항</a><span data-i18n="about.feature4Suffix">에서 확인</span></li>
        </ul>

        <h2 data-i18n="about.questionsTitle">궁금한 점이 있다면</h2>

        <p>
            <a href="<%= contextPath %>/support#faq" data-i18n="footer.faq">자주 묻는 질문</a><span data-i18n="about.questionsBody1">을 먼저 확인해 보시고,
            원하는 답을 못 찾았다면 같은 페이지의</span> <a href="<%= contextPath %>/support#contact" data-i18n="footer.contact">문의하기</a><span data-i18n="about.questionsBody2">에
            남겨주세요.</span>
        </p>

    </section>

</main>

<%@ include file="/common/footer.jsp" %>

</body>
</html>
