<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%@ page import="java.util.List" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="model.MemberDTO" %>
<%@ page import="model.PostDTO" %>
<%@ page import="util.EscapeUtil" %>

<%
    String contextPath = request.getContextPath();

    //이 페이지는 반드시 PostListCommand(/post/list)를 거쳐서 와야 한다.
    List<PostDTO> list = (List<PostDTO>) request.getAttribute("list");

    if (list == null) {
        response.sendRedirect(contextPath + "/post/list");
        return;
    }

    String country = (String) request.getAttribute("country");
    String style = (String) request.getAttribute("style");
    String region = (String) request.getAttribute("region");
    String keyword = (String) request.getAttribute("keyword");
    String sort = (String) request.getAttribute("sort");
    int pageNum = (Integer) request.getAttribute("page");
    int totalPages = (Integer) request.getAttribute("totalPages");
    int totalCount = (Integer) request.getAttribute("totalCount");

    //필터/정렬 링크에 지금 조건을 계속 붙여줘야 한다 (country만 바꿔도 검색어는 유지되도록)
    String encodedKeyword = URLEncoder.encode(keyword, "UTF-8");
    String baseQuery = "keyword=" + encodedKeyword;

    //페이지 번호 링크에 쓸, 현재 필터/정렬을 전부 포함한 쿼리스트링 (page만 바꿔 붙이면 됨)
    String pageQuery = "country=" + country + "&style=" + style + "&region=" + region
                      + "&sort=" + sort + "&" + baseQuery + "&page=";

    MemberDTO loginMember = (MemberDTO) session.getAttribute("loginMember");

    //PostController가 "글쓰기 금지" 등을 알리려고 세션에 남겨둔 1회성 메시지
    String flashMsg = (String) session.getAttribute("flashMsg");
    session.removeAttribute("flashMsg");

    //common/post-card.jspf가 쓰는 변수들
    boolean showMyBadge = false;
    String actionsHtml = null;
%>

<!DOCTYPE html>
<html lang="ko" <%= (loginMember != null && loginMember.isDarkMode()) ? "data-theme=\"dark\"" : "" %>>

<head>
    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title data-i18n="title.postsList">게시글 목록 - 여행만들기</title>

    <%@ include file="/common/css-links.jspf" %>
</head>

<body>

<!-- =========================
     상단 헤더
========================= -->

<% String activeNav = "posts"; %>
<%@ include file="/common/header.jsp" %>

<main>

    <!-- =========================
         페이지 타이틀
    ========================== -->

    <section class="page-heading">

        <p class="breadcrumb">
            <a href="<%= contextPath %>/main" data-i18n="nav.home">홈</a>
            〉 <span data-i18n="posts.title">게시글 목록</span>
        </p>

        <h1 data-i18n="posts.title">게시글 목록</h1>

        <p class="page-description" data-i18n="posts.pageDesc">
            국가와 여행 성향으로 원하는 여행 이야기를 찾아보세요.
        </p>

    </section>

    <% if (flashMsg != null) { %>
    <p class="field-error"><%= EscapeUtil.html(flashMsg) %></p>
    <% } %>

    <!-- =========================
         검색 및 필터
    ========================== -->

    <section class="filter-section">

        <form class="search-form"
              action="<%= contextPath %>/post/list"
              method="get">

            <input type="hidden" name="country" value="<%= country %>">
            <input type="hidden" name="style" value="<%= style %>">
            <input type="hidden" name="region" value="<%= region %>">
            <input type="hidden" name="sort" value="<%= sort %>">

            <label for="searchKeyword"
                   class="blind"
                   data-i18n="posts.searchLabel">
                게시글 검색
            </label>

            <input type="text"
                   id="searchKeyword"
                   name="keyword"
                   value="<%= EscapeUtil.html(keyword) %>"
                   data-i18n="posts.searchPlaceholder"
                   data-i18n-attr="placeholder"
                   placeholder="제목으로 검색해 보세요">

            <button type="submit" data-i18n="common.search">
                검색
            </button>

        </form>

        <div class="filter-group">

            <p class="filter-label" data-i18n="filter.country">국가</p>

            <a class="filter-button <%= "ALL".equals(country) ? "active" : "" %>" data-i18n="filter.all"
               href="<%= contextPath %>/post/list?country=ALL&style=<%= style %>&sort=<%= sort %>&<%= baseQuery %>">전체</a>
            <a class="filter-button <%= "KR".equals(country) ? "active" : "" %>" data-i18n="filter.korea"
               href="<%= contextPath %>/post/list?country=KR&style=<%= style %>&sort=<%= sort %>&<%= baseQuery %>">한국</a>
            <a class="filter-button <%= "JP".equals(country) ? "active" : "" %>" data-i18n="filter.japan"
               href="<%= contextPath %>/post/list?country=JP&style=<%= style %>&sort=<%= sort %>&<%= baseQuery %>">일본</a>
            <a class="filter-button <%= "ETC".equals(country) ? "active" : "" %>" data-i18n="filter.worldShort"
               href="<%= contextPath %>/post/list?country=ETC&style=<%= style %>&sort=<%= sort %>&<%= baseQuery %>">글로벌</a>

        </div>

        <div class="filter-group">

            <p class="filter-label" data-i18n="filter.style">여행 성향</p>

            <a class="filter-button <%= "ALL".equals(style) ? "active" : "" %>" data-i18n="filter.all"
               href="<%= contextPath %>/post/list?style=ALL&country=<%= country %>&region=<%= region %>&sort=<%= sort %>&<%= baseQuery %>">전체</a>
            <a class="filter-button <%= "healing".equals(style) ? "active" : "" %>" data-i18n="style.healing"
               href="<%= contextPath %>/post/list?style=healing&country=<%= country %>&region=<%= region %>&sort=<%= sort %>&<%= baseQuery %>">힐링</a>
            <a class="filter-button <%= "food".equals(style) ? "active" : "" %>" data-i18n="style.food"
               href="<%= contextPath %>/post/list?style=food&country=<%= country %>&region=<%= region %>&sort=<%= sort %>&<%= baseQuery %>">맛집</a>
            <a class="filter-button <%= "activity".equals(style) ? "active" : "" %>" data-i18n="style.activity"
               href="<%= contextPath %>/post/list?style=activity&country=<%= country %>&region=<%= region %>&sort=<%= sort %>&<%= baseQuery %>">액티비티</a>
            <a class="filter-button <%= "shopping".equals(style) ? "active" : "" %>" data-i18n="style.shopping"
               href="<%= contextPath %>/post/list?style=shopping&country=<%= country %>&region=<%= region %>&sort=<%= sort %>&<%= baseQuery %>">쇼핑</a>

        </div>

        <% if ("KR".equals(country)) { %>
        <div class="filter-group">

            <p class="filter-label" data-i18n="filter.regionDomestic">국내 지역</p>

            <a class="filter-button <%= "ALL".equals(region) ? "active" : "" %>" data-i18n="filter.all"
               href="<%= contextPath %>/post/list?region=ALL&country=KR&style=<%= style %>&sort=<%= sort %>&<%= baseQuery %>">전체</a>
            <a class="filter-button <%= "KR_CAPITAL".equals(region) ? "active" : "" %>" data-i18n="region.KR_CAPITAL"
               href="<%= contextPath %>/post/list?region=KR_CAPITAL&country=KR&style=<%= style %>&sort=<%= sort %>&<%= baseQuery %>">서울·경기·인천</a>
            <a class="filter-button <%= "KR_GANGWON".equals(region) ? "active" : "" %>" data-i18n="region.KR_GANGWON"
               href="<%= contextPath %>/post/list?region=KR_GANGWON&country=KR&style=<%= style %>&sort=<%= sort %>&<%= baseQuery %>">강원도</a>
            <a class="filter-button <%= "KR_CHUNGCHEONG".equals(region) ? "active" : "" %>" data-i18n="region.KR_CHUNGCHEONG"
               href="<%= contextPath %>/post/list?region=KR_CHUNGCHEONG&country=KR&style=<%= style %>&sort=<%= sort %>&<%= baseQuery %>">충청도</a>
            <a class="filter-button <%= "KR_JEOLLA".equals(region) ? "active" : "" %>" data-i18n="region.KR_JEOLLA"
               href="<%= contextPath %>/post/list?region=KR_JEOLLA&country=KR&style=<%= style %>&sort=<%= sort %>&<%= baseQuery %>">전라도</a>
            <a class="filter-button <%= "KR_GYEONGSANG".equals(region) ? "active" : "" %>" data-i18n="region.KR_GYEONGSANG"
               href="<%= contextPath %>/post/list?region=KR_GYEONGSANG&country=KR&style=<%= style %>&sort=<%= sort %>&<%= baseQuery %>">경상도</a>
            <a class="filter-button <%= "KR_JEJU".equals(region) ? "active" : "" %>" data-i18n="region.KR_JEJU"
               href="<%= contextPath %>/post/list?region=KR_JEJU&country=KR&style=<%= style %>&sort=<%= sort %>&<%= baseQuery %>">제주도</a>

        </div>
        <% } %>

        <% if ("JP".equals(country)) { %>
        <div class="filter-group">

            <p class="filter-label" data-i18n="filter.regionJapan">일본 지역</p>

            <a class="filter-button <%= "ALL".equals(region) ? "active" : "" %>" data-i18n="filter.all"
               href="<%= contextPath %>/post/list?region=ALL&country=JP&style=<%= style %>&sort=<%= sort %>&<%= baseQuery %>">전체</a>
            <a class="filter-button <%= "JP_HOKKAIDO".equals(region) ? "active" : "" %>" data-i18n="region.JP_HOKKAIDO"
               href="<%= contextPath %>/post/list?region=JP_HOKKAIDO&country=JP&style=<%= style %>&sort=<%= sort %>&<%= baseQuery %>">홋카이도 지방</a>
            <a class="filter-button <%= "JP_TOHOKU".equals(region) ? "active" : "" %>" data-i18n="region.JP_TOHOKU"
               href="<%= contextPath %>/post/list?region=JP_TOHOKU&country=JP&style=<%= style %>&sort=<%= sort %>&<%= baseQuery %>">도호쿠 지방</a>
            <a class="filter-button <%= "JP_KANTO".equals(region) ? "active" : "" %>" data-i18n="region.JP_KANTO"
               href="<%= contextPath %>/post/list?region=JP_KANTO&country=JP&style=<%= style %>&sort=<%= sort %>&<%= baseQuery %>">간토 지방</a>
            <a class="filter-button <%= "JP_CHUBU".equals(region) ? "active" : "" %>" data-i18n="region.JP_CHUBU"
               href="<%= contextPath %>/post/list?region=JP_CHUBU&country=JP&style=<%= style %>&sort=<%= sort %>&<%= baseQuery %>">주부 지방</a>
            <a class="filter-button <%= "JP_KANSAI".equals(region) ? "active" : "" %>" data-i18n="region.JP_KANSAI"
               href="<%= contextPath %>/post/list?region=JP_KANSAI&country=JP&style=<%= style %>&sort=<%= sort %>&<%= baseQuery %>">긴키·간사이 지방</a>
            <a class="filter-button <%= "JP_CHUGOKU".equals(region) ? "active" : "" %>" data-i18n="region.JP_CHUGOKU"
               href="<%= contextPath %>/post/list?region=JP_CHUGOKU&country=JP&style=<%= style %>&sort=<%= sort %>&<%= baseQuery %>">주고쿠 지방</a>
            <a class="filter-button <%= "JP_SHIKOKU".equals(region) ? "active" : "" %>" data-i18n="region.JP_SHIKOKU"
               href="<%= contextPath %>/post/list?region=JP_SHIKOKU&country=JP&style=<%= style %>&sort=<%= sort %>&<%= baseQuery %>">시코쿠 지방</a>
            <a class="filter-button <%= "JP_KYUSHU_OKINAWA".equals(region) ? "active" : "" %>" data-i18n="region.JP_KYUSHU_OKINAWA"
               href="<%= contextPath %>/post/list?region=JP_KYUSHU_OKINAWA&country=JP&style=<%= style %>&sort=<%= sort %>&<%= baseQuery %>">규슈·오키나와 지방</a>

        </div>
        <% } %>

    </section>

    <!-- =========================
         목록 헤더 (결과 수 / 정렬)
    ========================== -->

    <section class="list-heading">

        <p>
            <span data-i18n="posts.resultCount">전체 게시글</span> <strong><%= totalCount %></strong><span data-i18n="common.countSuffix">개</span>
        </p>

        <div class="sort-group">

            <a class="sort-button <%= "popular".equals(sort) ? "" : "active" %>" data-i18n="common.latestSort"
               href="<%= contextPath %>/post/list?sort=latest&country=<%= country %>&style=<%= style %>&region=<%= region %>&<%= baseQuery %>">최신순</a>
            <a class="sort-button <%= "popular".equals(sort) ? "active" : "" %>" data-i18n="common.popularSort"
               href="<%= contextPath %>/post/list?sort=popular&country=<%= country %>&style=<%= style %>&region=<%= region %>&<%= baseQuery %>">인기순</a>

        </div>

    </section>

    <!-- =========================
         게시글 목록
    ========================== -->

    <section class="post-list">

        <% for (PostDTO post : list) {

            boolean isMine = loginMember != null && loginMember.getId().equals(post.getWriter());
            //남의 글 수정은 admin(레벨 2)만, 삭제는 moderator(레벨 1)부터 가능하다.
            boolean canEdit = isMine || (loginMember != null && loginMember.isAdmin());
            boolean canDelete = isMine || (loginMember != null && loginMember.isModerator());

            showMyBadge = isMine;

            if (canEdit || canDelete) {
                actionsHtml = "<div class=\"detail-actions local-post-actions\">"
                    + (canEdit ? "<a href=\"" + contextPath + "/post/modify?bno=" + post.getBno() + "\" class=\"detail-edit-button\" data-i18n=\"common.edit\">수정</a>" : "")
                    + (canDelete
                        ? "<form method=\"post\" action=\"" + contextPath + "/post/delete\" onsubmit=\"return confirm(window.t('detail.confirmDeletePost', '이 게시글을 삭제하시겠습니까?'));\">"
                          + "<input type=\"hidden\" name=\"bno\" value=\"" + post.getBno() + "\">"
                          + "<button type=\"submit\" class=\"detail-delete-button\" data-i18n=\"common.delete\">삭제</button>"
                          + "</form>"
                        : "")
                    + "</div>";
            } else {
                actionsHtml = null;
            }
        %>
            <%@ include file="/common/post-card.jspf" %>
        <% } %>

    </section>

    <% if (list.isEmpty()) { %>
    <p class="empty-result" data-i18n="posts.emptyResult">
        조건에 맞는 게시글이 없습니다.
    </p>
    <% } %>

    <!-- =========================
         페이지네이션
    ========================== -->

    <% if (totalPages > 1) {

        //현재 페이지를 중심으로 최대 10개 번호만 보여준다 (전체가 많아도 버튼이 안 넘치게)
        int windowSize = 10;
        int startPage = Math.max(1, pageNum - windowSize / 2);
        int endPage = Math.min(totalPages, startPage + windowSize - 1);
        startPage = Math.max(1, endPage - windowSize + 1);
    %>
    <section class="pagination">

        <% if (pageNum > 1) { %>
        <a class="page-button" href="<%= contextPath %>/post/list?<%= pageQuery %><%= pageNum - 1 %>">‹</a>
        <% } %>

        <% for (int p = startPage; p <= endPage; p++) { %>
        <a class="page-button <%= p == pageNum ? "active" : "" %>"
           href="<%= contextPath %>/post/list?<%= pageQuery %><%= p %>"><%= p %></a>
        <% } %>

        <% if (pageNum < totalPages) { %>
        <a class="page-button" href="<%= contextPath %>/post/list?<%= pageQuery %><%= pageNum + 1 %>">›</a>
        <% } %>

    </section>
    <% } %>

</main>

<!-- =========================
     하단 푸터
========================= -->

<%@ include file="/common/footer.jsp" %>

</body>
</html>
