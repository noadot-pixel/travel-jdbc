<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%@ page import="model.MemberDTO" %>
<%@ page import="model.PostDTO" %>
<%@ page import="util.EscapeUtil" %>

<%
    String contextPath = request.getContextPath();

    MemberDTO loginMember = (MemberDTO) session.getAttribute("loginMember");

    if (loginMember == null) {
        response.sendRedirect(contextPath + "/member/login");
        return;
    }

    //PostModifyFormCommand(GET) 또는 실패 후 재진입한 PostModifyCommand(POST)가 넣어준 글.
    PostDTO post = (PostDTO) request.getAttribute("post");

    if (post == null) {
        response.sendRedirect(contextPath + "/post/list");
        return;
    }

    String msg = (String) request.getAttribute("msg");

    //실패해서 다시 돌아온 경우에는 방금 입력했던 값을 유지하고, 처음 들어온 경우에는 기존 글 값을 보여준다.
    String titleValue = request.getParameter("writeTitle") != null ? request.getParameter("writeTitle") : post.getTitle();
    String bodyValue = request.getParameter("writeBody") != null ? request.getParameter("writeBody") : post.getContent();
    String countryValue = request.getParameter("country") != null ? request.getParameter("country") : post.getCountry();
    String regionValue = request.getParameter("region") != null ? request.getParameter("region") : post.getRegion();
    String styleValue = request.getParameter("style") != null ? request.getParameter("style") : post.getStyle();

    long editJsVer = new java.io.File(application.getRealPath("/js/posts/edit.js")).lastModified();
%>

<!DOCTYPE html>
<html lang="ko" <%= (loginMember != null && loginMember.isDarkMode()) ? "data-theme=\"dark\"" : "" %>>

<head>
    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title data-i18n="title.postsEdit">게시글 수정 - 여행만들기</title>

    <%@ include file="/common/css-links.jspf" %>
</head>

<body class="composer-page">

<% String activeNav = "posts"; %>
<%@ include file="/common/header.jsp" %>

<main class="composer-page-main">

    <section class="page-heading">

        <p class="breadcrumb">
            <a href="<%= contextPath %>/main" data-i18n="nav.home">홈</a>
            〉 <a href="<%= contextPath %>/post/list" data-i18n="posts.title">게시글 목록</a>
            〉 <span data-i18n="edit.breadcrumb">게시글 수정</span>
        </p>

        <h1 data-i18n="edit.heading">게시글 수정</h1>

        <p class="page-description" data-i18n="edit.pageDesc">
            여행지 구분과 여행 성향을 각각 하나씩 선택하고 내용을 수정하세요.
        </p>

    </section>

    <% if (msg != null) { %>
    <p class="field-error"><%= EscapeUtil.html(msg) %></p>
    <% } %>

    <section class="write-section">

        <form id="editForm"
              method="post"
              action="<%= contextPath %>/post/modify">

            <input type="hidden" name="bno" value="<%= post.getBno() %>">

            <div class="composer-layout">

                <div class="composer-paper">

                    <div class="composer-section-heading">
                        <span class="composer-step">01</span>
                        <h2 data-i18n="editor.story">이야기 작성</h2>
                    </div>

                    <div class="write-field">

                        <label for="writeTitle" data-i18n="write.titleLabel">
                            제목
                        </label>

                        <input type="text"
                               id="writeTitle"
                               name="writeTitle"
                               value="<%= EscapeUtil.html(titleValue) %>"
                               data-i18n="write.titlePlaceholder"
                               data-i18n-attr="placeholder"
                               placeholder="제목을 입력해 주세요">

                    </div>

                    <div class="write-field">

                        <label for="writeBodyEditor" data-i18n="write.bodyLabel">
                            본문
                        </label>

                        <div id="writeBodyEditor" class="quill-editor-container"></div>
                        <input type="hidden" id="writeBody" name="writeBody">

                        <p class="write-field-note" data-i18n="write.bodyNote">
                            이미지 버튼으로 본문 중간에 사진을 넣을 수 있어요(10MB 미만). 본문의 첫 사진이
                            목록 카드 썸네일로 쓰이고, 사진이 없으면 여행지 구분에 맞는 기본 이미지가 쓰입니다.
                        </p>

                    </div>

                </div>

                <aside class="composer-settings" aria-label="여행 정보" data-i18n="editor.tripInfo" data-i18n-attr="aria-label">

                    <div class="composer-section-heading">
                        <span class="composer-step">02</span>
                        <h2 data-i18n="editor.tripInfo">여행 정보</h2>
                    </div>

                    <p class="composer-help" data-i18n="editor.tripHelp">이 이야기에 어울리는 여행지와 성향을 선택해 주세요.</p>

                    <input type="hidden" id="countryInput" name="country" value="<%= countryValue %>">
                    <input type="hidden" id="regionInput" name="region" value="<%= regionValue != null ? regionValue : "" %>">
                    <input type="hidden" id="styleInput" name="style" value="<%= styleValue %>">

                    <div class="filter-group" id="writeCountryGroup">

                        <p class="filter-label" data-i18n="write.countryGroupLabel">여행지 구분</p>

                        <button type="button" class="filter-button <%= "KR".equals(countryValue) ? "active" : "" %>" data-country="KR" data-i18n="write.countryDomestic">국내여행</button>
                        <button type="button" class="filter-button <%= "JP".equals(countryValue) ? "active" : "" %>" data-country="JP" data-i18n="write.countryJapan">일본여행</button>
                        <button type="button" class="filter-button <%= "ETC".equals(countryValue) ? "active" : "" %>" data-country="ETC" data-i18n="write.countryWorld">해외여행</button>

                    </div>

                    <div class="filter-group" id="writeKoreaRegionGroup" <%= "KR".equals(countryValue) ? "" : "hidden" %>>

                        <p class="filter-label" data-i18n="filter.regionDomestic">국내 지역</p>

                        <button type="button" class="filter-button <%= "KR_CAPITAL".equals(regionValue) ? "active" : "" %>" data-region="KR_CAPITAL" data-i18n="region.KR_CAPITAL">서울·경기·인천</button>
                        <button type="button" class="filter-button <%= "KR_GANGWON".equals(regionValue) ? "active" : "" %>" data-region="KR_GANGWON" data-i18n="region.KR_GANGWON">강원도</button>
                        <button type="button" class="filter-button <%= "KR_CHUNGCHEONG".equals(regionValue) ? "active" : "" %>" data-region="KR_CHUNGCHEONG" data-i18n="region.KR_CHUNGCHEONG">충청도</button>
                        <button type="button" class="filter-button <%= "KR_JEOLLA".equals(regionValue) ? "active" : "" %>" data-region="KR_JEOLLA" data-i18n="region.KR_JEOLLA">전라도</button>
                        <button type="button" class="filter-button <%= "KR_GYEONGSANG".equals(regionValue) ? "active" : "" %>" data-region="KR_GYEONGSANG" data-i18n="region.KR_GYEONGSANG">경상도</button>
                        <button type="button" class="filter-button <%= "KR_JEJU".equals(regionValue) ? "active" : "" %>" data-region="KR_JEJU" data-i18n="region.KR_JEJU">제주도</button>

                    </div>

                    <div class="filter-group" id="writeJapanRegionGroup" <%= "JP".equals(countryValue) ? "" : "hidden" %>>

                        <p class="filter-label" data-i18n="filter.regionJapan">일본 지역</p>

                        <button type="button" class="filter-button <%= "JP_HOKKAIDO".equals(regionValue) ? "active" : "" %>" data-region="JP_HOKKAIDO" data-i18n="region.JP_HOKKAIDO">홋카이도 지방</button>
                        <button type="button" class="filter-button <%= "JP_TOHOKU".equals(regionValue) ? "active" : "" %>" data-region="JP_TOHOKU" data-i18n="region.JP_TOHOKU">도호쿠 지방</button>
                        <button type="button" class="filter-button <%= "JP_KANTO".equals(regionValue) ? "active" : "" %>" data-region="JP_KANTO" data-i18n="region.JP_KANTO">간토 지방</button>
                        <button type="button" class="filter-button <%= "JP_CHUBU".equals(regionValue) ? "active" : "" %>" data-region="JP_CHUBU" data-i18n="region.JP_CHUBU">주부 지방</button>
                        <button type="button" class="filter-button <%= "JP_KANSAI".equals(regionValue) ? "active" : "" %>" data-region="JP_KANSAI" data-i18n="region.JP_KANSAI">긴키·간사이 지방</button>
                        <button type="button" class="filter-button <%= "JP_CHUGOKU".equals(regionValue) ? "active" : "" %>" data-region="JP_CHUGOKU" data-i18n="region.JP_CHUGOKU">주고쿠 지방</button>
                        <button type="button" class="filter-button <%= "JP_SHIKOKU".equals(regionValue) ? "active" : "" %>" data-region="JP_SHIKOKU" data-i18n="region.JP_SHIKOKU">시코쿠 지방</button>
                        <button type="button" class="filter-button <%= "JP_KYUSHU_OKINAWA".equals(regionValue) ? "active" : "" %>" data-region="JP_KYUSHU_OKINAWA" data-i18n="region.JP_KYUSHU_OKINAWA">규슈·오키나와 지방</button>

                    </div>

                    <div class="filter-group" id="writeStyleGroup">

                        <p class="filter-label" data-i18n="filter.style">여행 성향</p>

                        <button type="button" class="filter-button <%= "healing".equals(styleValue) ? "active" : "" %>" data-style="healing" data-i18n="style.healing">힐링</button>
                        <button type="button" class="filter-button <%= "food".equals(styleValue) ? "active" : "" %>" data-style="food" data-i18n="style.food">맛집</button>
                        <button type="button" class="filter-button <%= "activity".equals(styleValue) ? "active" : "" %>" data-style="activity" data-i18n="style.activity">액티비티</button>
                        <button type="button" class="filter-button <%= "shopping".equals(styleValue) ? "active" : "" %>" data-style="shopping" data-i18n="style.shopping">쇼핑</button>

                    </div>

                    <div class="composer-tip">
                        <strong data-i18n="editor.photoTipTitle">첫 사진이 대표 이미지가 돼요</strong>
                        <p data-i18n="editor.photoTip">여행의 분위기가 잘 드러나는 사진을 본문 맨 앞에 넣어 보세요.</p>
                    </div>

                </aside>

            </div>

            <div class="composer-actions">
                <span data-i18n="editor.publishHint">작성한 내용을 확인한 뒤 등록해 주세요.</span>
                <button type="submit" class="auth-submit" data-i18n="edit.submit">
                    수정하기
                </button>
            </div>

        </form>

    </section>

</main>

<%@ include file="/common/footer.jsp" %>
<%@ include file="/common/quill-assets.jspf" %>

<script>window.editInitialHtml = "<%= EscapeUtil.json(bodyValue) %>";</script>
<script src="<%= contextPath %>/js/posts/edit.js?v=<%= editJsVer %>"></script>

</body>
</html>
