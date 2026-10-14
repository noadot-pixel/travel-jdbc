<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%
    String contextPath = request.getContextPath();
%>

<!DOCTYPE html>
<html lang="ko">

<head>
    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>개인정보처리방침 - 여행만들기</title>

    <%@ include file="/common/css-links.jspf" %>
</head>

<body>

<% String activeNav = ""; %>
<%@ include file="/common/header.jsp" %>

<main>

    <section class="page-heading">

        <p class="breadcrumb">
            <a href="<%= contextPath %>/main">홈</a>
            〉 개인정보처리방침
        </p>

        <h1>개인정보처리방침</h1>

        <p class="page-description">
            여행만들기가 어떤 개인정보를 왜 모으는지 안내합니다.
        </p>

    </section>

    <section class="write-section policy-content">

        <p>
            '여행만들기'는 학습 목적으로 만들어진 개인/팀 프로젝트이며,
            수집한 개인정보를 영리 목적으로 판매하거나 외부 업체에 제공하지 않습니다.
        </p>

        <h2>1. 수집하는 개인정보 항목</h2>

        <ul>
            <li>필수(회원가입 시): 이메일(로그인 아이디), 비밀번호, 닉네임, 성별, 나이</li>
            <li>선택(마이페이지에서 직접 입력한 경우에만): 자기소개, 실명, 생일, 프로필 사진</li>
        </ul>

        <h2>2. 수집 목적</h2>

        <ul>
            <li>회원 식별 및 로그인</li>
            <li>게시글 작성자 표시</li>
            <li>성별 · 여행지별 인기 게시글 통계(랭킹) 화면 제공</li>
        </ul>

        <h2>3. 보유 기간</h2>

        <p>
            회원 탈퇴(계정 삭제) 시까지 보관하며, 삭제를 요청하면 지체 없이 삭제합니다.
        </p>

        <h2>4. 제3자 제공</h2>

        <p>
            수집한 개인정보를 외부 업체나 제3자에게 제공하지 않습니다.
        </p>

        <h2>5. 문의</h2>

        <p>
            개인정보와 관련해 궁금한 점이나 삭제 요청은 운영자에게 직접 연락해 주세요.
        </p>

    </section>

</main>

<%@ include file="/common/footer.jsp" %>

</body>
</html>
