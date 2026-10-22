<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%@ page import="model.MemberDTO" %>
<%@ page import="util.EscapeUtil" %>

<%
    String contextPath = request.getContextPath();

    //컨트롤러(PostController)가 이미 로그인을 확인하지만, 이 화면으로 직접 들어오는
    //경우까지 막도록 한 번 더 확인한다 (BlogProject의 write.jsp도 같은 방식).
    MemberDTO loginMember = (MemberDTO) session.getAttribute("loginMember");

    if (loginMember == null) {
        response.sendRedirect(contextPath + "/member/login");
        return;
    }

    String msg = (String) request.getAttribute("msg");   // 등록 실패 시 PostWriteCommand가 넣어준 메시지

    long writeJsVer = new java.io.File(application.getRealPath("/js/posts/write.js")).lastModified();
%>

<!DOCTYPE html>
<html lang="ko" <%= (loginMember != null && loginMember.isDarkMode()) ? "data-theme=\"dark\"" : "" %>>

<head>
    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title data-i18n="title.write">여행 이야기 작성 - 여행만들기</title>

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
            〉 <span data-i18n="nav.write">글쓰기</span>
        </p>

        <h1 data-i18n="write.heading">여행 이야기 작성</h1>

        <p class="page-description" data-i18n="write.pageDesc">
            여행지 구분과 여행 성향을 각각 하나씩 선택하고 이야기를 남겨보세요.
        </p>

    </section>

    <% if (msg != null) { %>
    <p class="field-error"><%= EscapeUtil.html(msg) %></p>
    <% } %>

    <section class="write-section">

        <!-- 사진은 에디터가 /post/uploadImage로 별도 업로드하므로, 이 폼 자체는 파일을 보내지 않는다 -->
        <form id="writeForm"
              method="post"
              action="<%= contextPath %>/post/write">

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
                               value="<%= EscapeUtil.html(request.getParameter("writeTitle")) %>"
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

                    <!-- 선택한 값은 JS가 이 hidden input에 채워서 서버로 보낸다 -->
                    <input type="hidden" id="countryInput" name="country" value="">
                    <input type="hidden" id="regionInput" name="region" value="">
                    <input type="hidden" id="styleInput" name="style" value="">

                    <div class="filter-group" id="writeCountryGroup">

                        <p class="filter-label" data-i18n="write.countryGroupLabel">여행지 구분</p>

                        <button type="button" class="filter-button" data-country="KR" data-i18n="write.countryDomestic">국내여행</button>
                        <button type="button" class="filter-button" data-country="JP" data-i18n="write.countryJapan">일본여행</button>
                        <button type="button" class="filter-button" data-country="ETC" data-i18n="write.countryWorld">해외여행</button>

                    </div>

                    <!-- 국내여행을 선택했을 때만 보여준다 -->
                    <div class="filter-group" id="writeKoreaRegionGroup" hidden>

                        <p class="filter-label" data-i18n="filter.regionDomestic">국내 지역</p>

                        <button type="button" class="filter-button" data-region="KR_CAPITAL" data-i18n="region.KR_CAPITAL">서울·경기·인천</button>
                        <button type="button" class="filter-button" data-region="KR_GANGWON" data-i18n="region.KR_GANGWON">강원도</button>
                        <button type="button" class="filter-button" data-region="KR_CHUNGCHEONG" data-i18n="region.KR_CHUNGCHEONG">충청도</button>
                        <button type="button" class="filter-button" data-region="KR_JEOLLA" data-i18n="region.KR_JEOLLA">전라도</button>
                        <button type="button" class="filter-button" data-region="KR_GYEONGSANG" data-i18n="region.KR_GYEONGSANG">경상도</button>
                        <button type="button" class="filter-button" data-region="KR_JEJU" data-i18n="region.KR_JEJU">제주도</button>

                    </div>

                    <!-- 일본여행을 선택했을 때만 보여준다 -->
                    <div class="filter-group" id="writeJapanRegionGroup" hidden>

                        <p class="filter-label" data-i18n="filter.regionJapan">일본 지역</p>

                        <button type="button" class="filter-button" data-region="JP_HOKKAIDO" data-i18n="region.JP_HOKKAIDO">홋카이도 지방</button>
                        <button type="button" class="filter-button" data-region="JP_TOHOKU" data-i18n="region.JP_TOHOKU">도호쿠 지방</button>
                        <button type="button" class="filter-button" data-region="JP_KANTO" data-i18n="region.JP_KANTO">간토 지방</button>
                        <button type="button" class="filter-button" data-region="JP_CHUBU" data-i18n="region.JP_CHUBU">주부 지방</button>
                        <button type="button" class="filter-button" data-region="JP_KANSAI" data-i18n="region.JP_KANSAI">긴키·간사이 지방</button>
                        <button type="button" class="filter-button" data-region="JP_CHUGOKU" data-i18n="region.JP_CHUGOKU">주고쿠 지방</button>
                        <button type="button" class="filter-button" data-region="JP_SHIKOKU" data-i18n="region.JP_SHIKOKU">시코쿠 지방</button>
                        <button type="button" class="filter-button" data-region="JP_KYUSHU_OKINAWA" data-i18n="region.JP_KYUSHU_OKINAWA">규슈·오키나와 지방</button>

                    </div>

                    <div class="filter-group" id="writeStyleGroup">

                        <p class="filter-label" data-i18n="filter.style">여행 성향</p>

                        <button type="button" class="filter-button" data-style="healing" data-i18n="style.healing">힐링</button>
                        <button type="button" class="filter-button" data-style="food" data-i18n="style.food">맛집</button>
                        <button type="button" class="filter-button" data-style="activity" data-i18n="style.activity">액티비티</button>
                        <button type="button" class="filter-button" data-style="shopping" data-i18n="style.shopping">쇼핑</button>

                    </div>

                    <div class="composer-tip">
                        <strong data-i18n="editor.photoTipTitle">첫 사진이 대표 이미지가 돼요</strong>
                        <p data-i18n="editor.photoTip">여행의 분위기가 잘 드러나는 사진을 본문 맨 앞에 넣어 보세요.</p>
                    </div>

                </aside>

            </div>

            <div class="composer-actions">
                <span data-i18n="editor.publishHint">작성한 내용을 확인한 뒤 등록해 주세요.</span>
                <button type="submit" class="auth-submit" data-i18n="write.submit">
                    등록하기
                </button>
            </div>

        </form>

    </section>

</main>

<%@ include file="/common/footer.jsp" %>
<%@ include file="/common/quill-assets.jspf" %>

<script src="<%= contextPath %>/js/posts/write.js?v=<%= writeJsVer %>"></script>

</body>
</html>
