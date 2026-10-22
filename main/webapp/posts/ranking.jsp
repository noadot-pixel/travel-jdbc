<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%@ page import="java.util.List" %>
<%@ page import="model.MemberDTO" %>
<%@ page import="model.RegionRankDTO" %>
<%@ page import="util.EscapeUtil" %>

<%
    String contextPath = request.getContextPath();

    MemberDTO themeMember = (MemberDTO) session.getAttribute("loginMember");

    String country = (String) request.getAttribute("country");
    List<RegionRankDTO> maleRanking = (List<RegionRankDTO>) request.getAttribute("maleRanking");
    List<RegionRankDTO> femaleRanking = (List<RegionRankDTO>) request.getAttribute("femaleRanking");
    List<RegionRankDTO> totalRanking = (List<RegionRankDTO>) request.getAttribute("totalRanking");

    //상위 3위는 숫자(#1) 대신 메달 이모지로 표시한다 (번역이 필요 없어서 i18n 사전과 무관하게 항상 보임).
    String[] rankMedals = { "🥇", "🥈", "🥉" };

    String countryLabel = "JP".equals(country) ? "일본" : "한국";
    String countryI18nKey = "JP".equals(country) ? "country.JP" : "country.KR";

    //Cloudflare가 정적 파일(svg)을 기본 4시간 엣지 캐시로 들고 있어서, css-links.jspf와
    //같은 방식으로 파일 수정 시각을 쿼리스트링에 붙여 수정할 때마다 새로 받아오게 한다.
    String mapSvgFile = "JP".equals(country) ? "japan-regions.svg" : "korea-regions.svg";
    long mapSvgVer = new java.io.File(application.getRealPath("/images/maps/" + mapSvgFile)).lastModified();

    //지도가 fetch로 불러와지기 전에도 카드 높이를 미리 잡아둬서(각 지도의 viewBox 비율대로)
    //로딩 중에 레이아웃이 출렁이지 않게 한다.
    String mapAspectRatio = "JP".equals(country) ? "745 / 815" : "550 / 745";

    //지도 색칠용 JSON - {"KR_CAPITAL":12,"KR_GANGWON":3,...} 형태로 JS에 넘긴다.
    //전체/남성/여성 세 버전을 따로 만들어서, 지도 우측 상단 라디오로 바로 전환할 수 있게 한다.
    StringBuilder regionCountsJson = new StringBuilder("{");
    for (int i = 0; i < totalRanking.size(); i++) {
        if (i > 0) regionCountsJson.append(",");
        RegionRankDTO row = totalRanking.get(i);
        regionCountsJson.append("\"").append(row.getRegion()).append("\":").append(row.getPostCount());
    }
    regionCountsJson.append("}");

    StringBuilder maleRegionCountsJson = new StringBuilder("{");
    for (int i = 0; i < maleRanking.size(); i++) {
        if (i > 0) maleRegionCountsJson.append(",");
        RegionRankDTO row = maleRanking.get(i);
        maleRegionCountsJson.append("\"").append(row.getRegion()).append("\":").append(row.getPostCount());
    }
    maleRegionCountsJson.append("}");

    StringBuilder femaleRegionCountsJson = new StringBuilder("{");
    for (int i = 0; i < femaleRanking.size(); i++) {
        if (i > 0) femaleRegionCountsJson.append(",");
        RegionRankDTO row = femaleRanking.get(i);
        femaleRegionCountsJson.append("\"").append(row.getRegion()).append("\":").append(row.getPostCount());
    }
    femaleRegionCountsJson.append("}");

    String topPostsByRegionJson = (String) request.getAttribute("topPostsByRegionJson");
    if (topPostsByRegionJson == null) topPostsByRegionJson = "{}";

    long rankingJsVer = new java.io.File(application.getRealPath("/js/posts/ranking.js")).lastModified();
%>

<!DOCTYPE html>
<html lang="ko" <%= (themeMember != null && themeMember.isDarkMode()) ? "data-theme=\"dark\"" : "" %>>

<head>
    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title data-i18n="title.ranking">게시글 랭킹 - 여행만들기</title>

    <%@ include file="/common/css-links.jspf" %>
</head>

<body>

<% String activeNav = "ranking"; %>
<%@ include file="/common/header.jsp" %>

<main>

    <section class="page-heading ranking-heading">

        <div>
            <p class="breadcrumb">
                <a href="<%= contextPath %>/main" data-i18n="nav.home">홈</a>
                〉 <span data-i18n="ranking.title">게시글 랭킹</span>
            </p>

            <h1 data-i18n="ranking.title">게시글 랭킹</h1>

            <p class="page-description" data-i18n="ranking.pageDesc">
                게시글 개수를 기준으로 성별 · 여행지별 인기 지역을 보여줍니다.
            </p>
        </div>

        <div class="ranking-switch">
            <a class="filter-button <%= "KR".equals(country) ? "active" : "" %>" data-i18n="ranking.korea"
               href="<%= contextPath %>/post/ranking?country=KR">한국여행지</a>
            <a class="filter-button <%= "JP".equals(country) ? "active" : "" %>" data-i18n="ranking.japan"
               href="<%= contextPath %>/post/ranking?country=JP">일본여행지</a>
        </div>

    </section>

    <section class="ranking-section">

        <div class="ranking-layout">

            <!-- =========================
                 지역별 게시글 분포 지도
            ========================== -->

            <div class="ranking-map-col">


                <div class="region-map-wrap">
                    <div class="region-map-container"
                         id="regionMapContainer"
                         style="aspect-ratio: <%= mapAspectRatio %>;"
                         data-map-src="<%= contextPath %>/images/maps/<%= mapSvgFile %>?v=<%= mapSvgVer %>"></div>
                    <div class="region-map-gender-filter" id="regionMapGenderFilter">

                        <label class="theme-option active">
                            <input type="radio" name="regionMapGender" value="all" checked>
                            <span data-i18n="ranking.mapFilterAll">전체</span>
                        </label>

                        <label class="theme-option">
                            <input type="radio" name="regionMapGender" value="M">
                            <span data-i18n="gender.male">남성</span>
                        </label>

                        <label class="theme-option">
                            <input type="radio" name="regionMapGender" value="F">
                            <span data-i18n="gender.female">여성</span>
                        </label>

                    </div>
                    <div class="region-map-tooltip" id="regionMapTooltip" hidden></div>
                    <div class="region-map-legend" aria-hidden="true">
                        <span class="ranking-map-legend-label" data-i18n="ranking.mapLegendLow">적음</span>
                        <span class="ranking-map-legend-bar"></span>
                        <span class="ranking-map-legend-label" data-i18n="ranking.mapLegendHigh">많음</span>
                    </div>
                    <div class="region-map-zoom-controls">
                        <button type="button" class="region-map-zoom-button" id="regionMapZoomIn" data-i18n="ranking.zoomInAriaLabel" data-i18n-attr="aria-label" aria-label="확대">+</button>
                        <button type="button" class="region-map-zoom-button" id="regionMapZoomOut" data-i18n="ranking.zoomOutAriaLabel" data-i18n-attr="aria-label" aria-label="축소">−</button>
                        <button type="button" class="region-map-zoom-button region-map-zoom-reset" id="regionMapZoomReset" data-i18n="ranking.zoomResetAriaLabel" data-i18n-attr="aria-label" aria-label="보기 초기화">⟲</button>
                    </div>
                </div>

            </div>

            <div class="ranking-lists-col">

                <div class="ranking-column ranking-column-male">

                    <h2 class="ranking-column-title"><span data-i18n="ranking.male">남성 인기 지역</span> - <span data-i18n="<%= countryI18nKey %>"><%= countryLabel %></span></h2>

                    <% if (maleRanking.isEmpty()) { %>
                    <p class="ranking-empty" data-i18n="ranking.empty">아직 집계된 게시글이 없습니다.</p>
                    <% } else { %>
                    <ol class="ranking-list">
                        <% for (int i = 0; i < maleRanking.size(); i++) {
                            RegionRankDTO row = maleRanking.get(i);
                            String rankClass = i < 3 ? " rank-" + (i + 1) : "";
                        %>
                        <li class="ranking-item<%= rankClass %>">
                            <a href="<%= contextPath %>/post/list?country=<%= country %>&region=<%= row.getRegion() %>">
                                <span class="ranking-rank"><%= i < 3 ? rankMedals[i] : ("#" + (i + 1)) %></span>
                                <span class="ranking-region" data-i18n="region.<%= row.getRegion() %>"><%= EscapeUtil.html(row.getRegionLabel()) %></span>
                                <span class="ranking-count"><%= row.getPostCount() %><span data-i18n="common.countSuffix">개</span></span>
                            </a>
                        </li>
                        <% } %>
                    </ol>
                    <% } %>

                </div>

                <div class="ranking-column ranking-column-female">

                    <h2 class="ranking-column-title"><span data-i18n="ranking.female">여성 인기 지역</span> - <span data-i18n="<%= countryI18nKey %>"><%= countryLabel %></span></h2>

                    <% if (femaleRanking.isEmpty()) { %>
                    <p class="ranking-empty" data-i18n="ranking.empty">아직 집계된 게시글이 없습니다.</p>
                    <% } else { %>
                    <ol class="ranking-list">
                        <% for (int i = 0; i < femaleRanking.size(); i++) {
                            RegionRankDTO row = femaleRanking.get(i);
                            String rankClass = i < 3 ? " rank-" + (i + 1) : "";
                        %>
                        <li class="ranking-item<%= rankClass %>">
                            <a href="<%= contextPath %>/post/list?country=<%= country %>&region=<%= row.getRegion() %>">
                                <span class="ranking-rank"><%= i < 3 ? rankMedals[i] : ("#" + (i + 1)) %></span>
                                <span class="ranking-region" data-i18n="region.<%= row.getRegion() %>"><%= EscapeUtil.html(row.getRegionLabel()) %></span>
                                <span class="ranking-count"><%= row.getPostCount() %><span data-i18n="common.countSuffix">개</span></span>
                            </a>
                        </li>
                        <% } %>
                    </ol>
                    <% } %>

                </div>

            </div>

        </div>

        <p class="ranking-note" data-i18n="ranking.note">
            ※ 성별 정보를 입력한 회원이 쓴 글만 집계됩니다. (이 기능 이전 가입자는 제외)
        </p>

    </section>

</main>

<%@ include file="/common/footer.jsp" %>

<script>
    window.rankingData = {
        country: "<%= country %>",
        regionCounts: {
            all: <%= regionCountsJson.toString() %>,
            M: <%= maleRegionCountsJson.toString() %>,
            F: <%= femaleRegionCountsJson.toString() %>
        },
        topPostsByRegion: <%= topPostsByRegionJson %>
    };
</script>
<script src="<%= contextPath %>/js/posts/ranking.js?v=<%= rankingJsVer %>"></script>

</body>
</html>
