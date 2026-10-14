<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%@ page import="java.util.List" %>
<%@ page import="model.RegionRankDTO" %>
<%@ page import="util.EscapeUtil" %>

<%
    String contextPath = request.getContextPath();

    String country = (String) request.getAttribute("country");
    List<RegionRankDTO> maleRanking = (List<RegionRankDTO>) request.getAttribute("maleRanking");
    List<RegionRankDTO> femaleRanking = (List<RegionRankDTO>) request.getAttribute("femaleRanking");

    String countryLabel = "JP".equals(country) ? "일본 여행지" : "한국 여행지";
%>

<!DOCTYPE html>
<html lang="ko">

<head>
    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>게시글 랭킹 - 여행만들기</title>

    <%@ include file="/common/css-links.jspf" %>
</head>

<body>

<% String activeNav = "ranking"; %>
<%@ include file="/common/header.jsp" %>

<main>

    <section class="page-heading ranking-heading">

        <div>
            <p class="breadcrumb">
                <a href="<%= contextPath %>/main">홈</a>
                〉 게시글 랭킹
            </p>

            <h1>게시글 랭킹</h1>

            <p class="page-description">
                게시글 개수를 기준으로 성별 · 여행지별 인기 지역을 보여줍니다.
            </p>
        </div>

        <div class="ranking-switch">
            <a class="filter-button <%= "KR".equals(country) ? "active" : "" %>"
               href="<%= contextPath %>/post/ranking?country=KR">한국여행지</a>
            <a class="filter-button <%= "JP".equals(country) ? "active" : "" %>"
               href="<%= contextPath %>/post/ranking?country=JP">일본여행지</a>
        </div>

    </section>

    <section class="ranking-section">

        <div class="ranking-columns">

            <div class="ranking-column">

                <h2 class="ranking-column-title">남성 인기 지역 - <%= countryLabel %></h2>

                <% if (maleRanking.isEmpty()) { %>
                <p class="ranking-empty">아직 집계된 게시글이 없습니다.</p>
                <% } else { %>
                <ol class="ranking-list">
                    <% for (int i = 0; i < maleRanking.size(); i++) {
                        RegionRankDTO row = maleRanking.get(i);
                    %>
                    <li class="ranking-item">
                        <span class="ranking-rank">#<%= i + 1 %></span>
                        <span class="ranking-region"><%= EscapeUtil.html(row.getRegionLabel()) %></span>
                        <span class="ranking-count"><%= row.getPostCount() %>개</span>
                    </li>
                    <% } %>
                </ol>
                <% } %>

            </div>

            <div class="ranking-column">

                <h2 class="ranking-column-title">여성 인기 지역 - <%= countryLabel %></h2>

                <% if (femaleRanking.isEmpty()) { %>
                <p class="ranking-empty">아직 집계된 게시글이 없습니다.</p>
                <% } else { %>
                <ol class="ranking-list">
                    <% for (int i = 0; i < femaleRanking.size(); i++) {
                        RegionRankDTO row = femaleRanking.get(i);
                    %>
                    <li class="ranking-item">
                        <span class="ranking-rank">#<%= i + 1 %></span>
                        <span class="ranking-region"><%= EscapeUtil.html(row.getRegionLabel()) %></span>
                        <span class="ranking-count"><%= row.getPostCount() %>개</span>
                    </li>
                    <% } %>
                </ol>
                <% } %>

            </div>

        </div>

        <p class="ranking-note">
            ※ 성별 정보를 입력한 회원이 쓴 글만 집계됩니다. (이 기능 이전 가입자는 제외)
        </p>

    </section>

</main>

<%@ include file="/common/footer.jsp" %>

</body>
</html>
