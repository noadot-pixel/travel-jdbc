<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%@ page import="java.util.List" %>
<%@ page import="model.MemberDTO" %>
<%@ page import="model.PostDTO" %>
<%@ page import="util.EscapeUtil" %>

<%
    String contextPath = request.getContextPath();

    MemberDTO themeMember = (MemberDTO) session.getAttribute("loginMember");

    //이 페이지는 반드시 MainCommand(/main)를 거쳐서 와야 한다. 직접 열면 데이터가 없으므로 돌려보낸다.
    List<PostDTO> koreaPosts = (List<PostDTO>) request.getAttribute("koreaPosts");

    if (koreaPosts == null) {
        response.sendRedirect(contextPath + "/main");
        return;
    }

    List<PostDTO> japanPosts = (List<PostDTO>) request.getAttribute("japanPosts");
    List<PostDTO> worldPosts = (List<PostDTO>) request.getAttribute("worldPosts");

    //common/post-card.jspf가 쓰는 변수들. 메인 화면은 수정/삭제 버튼도, "내 글" 배지도 없다.
    boolean showMyBadge = false;
    String actionsHtml = null;
%>

<!DOCTYPE html>
<html lang="ko" <%= (themeMember != null && themeMember.isDarkMode()) ? "data-theme=\"dark\"" : "" %>>

<head>
    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>여행만들기</title>

    <%@ include file="/common/css-links.jspf" %>
</head>

<body>

<!-- =========================
     상단 헤더
========================= -->

<% String activeNav = "home"; %>
<%@ include file="/common/header.jsp" %>

<main>

    <!-- =========================
         메인 이미지
    ========================== -->

    <section class="main-visual">

        <div class="main-overlay"></div>

        <div class="main-content">

            <p class="main-label">
                KOREA · JAPAN · WORLD
            </p>

            <h1>
                <span data-i18n="home.heroTitle">여행을 만들면</span>
                <span class="hero-title-highlight" data-i18n="home.heroTitleHighlight">새로운 이야기가 시작된다</span>
            </h1>

            <p class="main-description" data-i18n="home.heroDesc">
                한국과 일본, 우리들의 특별한 여행을 함께 만들어가는 여행 커뮤니티입니다.
            </p>

            <form class="search-form"
                  action="<%= contextPath %>/post/list"
                  method="get">

                <label for="searchKeyword"
                       class="blind"
                       data-i18n="home.searchLabel">
                    여행지 검색
                </label>

                <span class="search-icon">
                    ⌕
                </span>

                <input type="text"
                       id="searchKeyword"
                       name="keyword"
                       data-i18n="home.searchPlaceholder"
                       data-i18n-attr="placeholder"
                       placeholder="어디로 떠나고 싶으신가요?">

                <button type="submit" data-i18n="common.search">
                    검색
                </button>

            </form>

            <div class="recommend-keywords">

                <button type="button" data-keyword="서울" data-i18n="home.keyword.seoul">#서울</button>
                <button type="button" data-keyword="제주도" data-i18n="home.keyword.jeju">#제주도</button>
                <button type="button" data-keyword="도쿄" data-i18n="home.keyword.tokyo">#도쿄</button>
                <button type="button" data-keyword="오사카" data-i18n="home.keyword.osaka">#오사카</button>
                <button type="button" data-keyword="후쿠오카" data-i18n="home.keyword.fukuoka">#후쿠오카</button>
                <button type="button" data-keyword="바르셀로나" data-i18n="home.keyword.barcelona">#바르셀로나</button>

            </div>

        </div>

    </section>

    <!-- =========================
         여행 카테고리
    ========================== -->

    <section class="category-section"
             id="travelCategory">

        <div class="section-heading">

            <h2 data-i18n="home.categoryHeading">여행 카테고리</h2>

            <a href="<%= contextPath %>/post/list" data-i18n="common.viewAll">
                전체보기 〉
            </a>

        </div>

        <div class="category-carousel">

            <button type="button"
                    class="category-nav category-nav-prev"
                    id="categoryPrev"
                    aria-label="이전 카테고리">
                ‹
            </button>

            <div class="category-viewport">

            <div class="category-list" id="categoryTrack">

            <!-- 한국 여행지 -->
            <a href="<%= contextPath %>/post/list?country=KR"
               class="category-card">

                <img src="<%= contextPath %>/images/korea.jpg"
                     alt="한국 여행지">

                <div class="category-content">

                    <h3 data-i18n="home.category.korea.title">한국 여행지</h3>

                    <p data-i18n="home.category.korea.desc">
                        국내의 아름다운 여행지를 만나보세요.
                    </p>

                </div>

            </a>

            <!-- 일본 여행지 -->
            <a href="<%= contextPath %>/post/list?country=JP"
               class="category-card">

                <img src="<%= contextPath %>/images/japan.jpg"
                     alt="일본 여행지">

                <div class="category-content">

                    <h3 data-i18n="home.category.japan.title">일본 여행지</h3>

                    <p data-i18n="home.category.japan.desc">
                        가깝고도 새로운 일본을 여행해 보세요.
                    </p>

                </div>

            </a>

            <!-- 세계 여행지 -->
            <a href="<%= contextPath %>/post/list?country=ETC"
               class="category-card">

                <img src="<%= contextPath %>/images/world.jpg"
                     alt="세계 여행지">

                <div class="category-content">

                    <h3 data-i18n="home.category.world.title">세계 여행지</h3>

                    <p data-i18n="home.category.world.desc">
                        더 멀리, 더 새로운 세계로 떠나보세요.
                    </p>

                </div>

            </a>

            <!-- 여행지 맛집 -->
            <a href="<%= contextPath %>/post/list?style=food"
               class="category-card">

                <img src="<%= contextPath %>/images/travel_food.jpg"
                     alt="여행지 맛집">

                <div class="category-content">

                    <h3 data-i18n="home.category.food.title">여행지 맛집</h3>

                    <p data-i18n="home.category.food.desc">
                        여행에서 놓칠 수 없는 맛집을 소개합니다.
                    </p>

                </div>

            </a>

            <!-- 힐링 여행 (임시 이미지, 추후 교체 예정) -->
            <a href="<%= contextPath %>/post/list?style=healing"
               class="category-card">

                <img src="<%= contextPath %>/images/jeju.jpg"
                     alt="힐링 여행">

                <div class="category-content">

                    <h3 data-i18n="home.category.healing.title">힐링 여행</h3>

                    <p data-i18n="home.category.healing.desc">
                        몸과 마음이 쉬어가는 여행지를 만나보세요.
                    </p>

                </div>

            </a>

            <!-- 액티비티 여행 (임시 이미지, 추후 교체 예정) -->
            <a href="<%= contextPath %>/post/list?style=activity"
               class="category-card">

                <img src="<%= contextPath %>/images/barcelona.jpg"
                     alt="액티비티 여행">

                <div class="category-content">

                    <h3 data-i18n="home.category.activity.title">액티비티 여행</h3>

                    <p data-i18n="home.category.activity.desc">
                        짜릿한 경험이 가득한 여행을 떠나보세요.
                    </p>

                </div>

            </a>

            <!-- 쇼핑 여행 (임시 이미지, 추후 교체 예정) -->
            <a href="<%= contextPath %>/post/list?style=shopping"
               class="category-card">

                <img src="<%= contextPath %>/images/fukuoka.jpg"
                     alt="쇼핑 여행">

                <div class="category-content">

                    <h3 data-i18n="home.category.shopping.title">쇼핑 여행</h3>

                    <p data-i18n="home.category.shopping.desc">
                        알찬 쇼핑으로 완성하는 여행을 만나보세요.
                    </p>

                </div>

            </a>

            </div>

            </div>

            <button type="button"
                    class="category-nav category-nav-next"
                    id="categoryNext"
                    aria-label="다음 카테고리">
                ›
            </button>

        </div>

    </section>

    <!-- =========================
         국가별 최신 게시물
    ========================== -->

    <section class="story-section"
             id="travelStory">

        <div class="section-heading">

            <h2>📝 <span data-i18n="home.storyHeading">최신 여행 이야기</span></h2>

            <a href="<%= contextPath %>/post/list" data-i18n="common.viewAll">
                전체보기 〉
            </a>

        </div>

        <!-- =====================
             한국 여행지
        ====================== -->

        <section class="country-board">

            <div class="country-heading">

                <h3>🌺 <span data-i18n="home.country.korea">한국 여행지</span></h3>

                <div class="country-heading-right">

                    <span data-i18n="common.latestSort">최신순</span>

                    <a href="<%= contextPath %>/post/list?country=KR" data-i18n="common.viewMore">
                        더보기 〉
                    </a>

                </div>

            </div>

            <div class="country-card-list">

                <% for (PostDTO post : koreaPosts) { %>
                    <%@ include file="/common/post-card.jspf" %>
                <% }
                   for (int i = koreaPosts.size(); i < 3; i++) { %>
                    <article class="empty-story-card" data-empty="true">
                        <div class="empty-folder">📁</div>
                        <p data-i18n="home.emptyStory.korea">새로운 한국 여행 이야기가 등록될 공간입니다.</p>
                    </article>
                <% } %>

            </div>

        </section>

        <!-- =====================
             일본 여행지
        ====================== -->

        <section class="country-board">

            <div class="country-heading">

                <h3>🍣 <span data-i18n="home.country.japan">일본 여행지</span></h3>

                <div class="country-heading-right">

                    <span data-i18n="common.latestSort">최신순</span>

                    <a href="<%= contextPath %>/post/list?country=JP" data-i18n="common.viewMore">
                        더보기 〉
                    </a>

                </div>

            </div>

            <div class="country-card-list">

                <% for (PostDTO post : japanPosts) { %>
                    <%@ include file="/common/post-card.jspf" %>
                <% }
                   for (int i = japanPosts.size(); i < 3; i++) { %>
                    <article class="empty-story-card" data-empty="true">
                        <div class="empty-folder">📁</div>
                        <p data-i18n="home.emptyStory.japan">새로운 일본 여행 이야기가 등록될 공간입니다.</p>
                    </article>
                <% } %>

            </div>

        </section>

        <!-- =====================
             세계 여행지
        ====================== -->

        <section class="country-board">

            <div class="country-heading">

                <h3>🌍 <span data-i18n="home.country.world">세계 여행지</span></h3>

                <div class="country-heading-right">

                    <span data-i18n="common.latestSort">최신순</span>

                    <a href="<%= contextPath %>/post/list?country=ETC" data-i18n="common.viewMore">
                        더보기 〉
                    </a>

                </div>

            </div>

            <div class="country-card-list">

                <% for (PostDTO post : worldPosts) { %>
                    <%@ include file="/common/post-card.jspf" %>
                <% }
                   for (int i = worldPosts.size(); i < 3; i++) { %>
                    <article class="empty-story-card" data-empty="true">
                        <div class="empty-folder">📁</div>
                        <p data-i18n="home.emptyStory.world">새로운 세계 여행 이야기가 등록될 공간입니다.</p>
                    </article>
                <% } %>

            </div>

        </section>

    </section>

    <!-- =========================
         하단 전체 사진
    ========================== -->

    <section class="footer-visual">

        <div class="footer-visual-overlay"></div>

        <div class="footer-visual-content">

            <h2 data-i18n="home.footerVisual.title">
                좋은 사람들과 함께 만드는 여행
            </h2>

            <p data-i18n="home.footerVisual.desc">
                새로운 여행 이야기를 여행만들기에서 함께 공유해 보세요.
            </p>

            <a href="<%= contextPath %>/post/write" data-i18n="home.footerVisual.cta">
                여행 이야기 작성하기
            </a>

        </div>

    </section>

</main>

<!-- =========================
     하단 푸터
========================= -->

<%@ include file="/common/footer.jsp" %>

<script>
    /*
     * 추천 검색어를 클릭하면 검색창에 입력
     */

    const searchInput =
        document.getElementById("searchKeyword");

    document.querySelectorAll(".recommend-keywords button").forEach(function (button) {

        button.addEventListener("click", function () {

            searchInput.value = button.dataset.keyword;

            searchInput.focus();
        });

    });

    /*
     * 여행 카테고리 캐러셀 - 기본 4개만 보이고, </>버튼으로 한 칸씩 이동한다.
     * 끝(쇼핑 여행)에서 다음을 누르면 처음(한국 여행지)으로, 처음에서 이전을 누르면
     * 끝으로 돌아간다 (루프). 모바일(767px 이하)은 버튼 없이 손가락 스와이프로
     * 넘기는 방식이라(mobile.css) 이 스크립트가 끼어들지 않게 뷰포트 너비를 확인한다.
     */

    (function () {

        const track = document.getElementById("categoryTrack");
        const prevButton = document.getElementById("categoryPrev");
        const nextButton = document.getElementById("categoryNext");

        if (!track || !prevButton || !nextButton) {
            return;
        }

        const cards = Array.prototype.slice.call(track.children);
        const visible = 4;
        const maxIndex = Math.max(0, cards.length - visible);
        let index = 0;

        function isCarouselActive() {
            return window.innerWidth > 767 && cards.length > visible;
        }

        function update() {

            if (!isCarouselActive()) {
                track.style.transform = "";
                return;
            }

            const gap = parseFloat(getComputedStyle(track).columnGap || getComputedStyle(track).gap || "0");
            const step = cards[0].getBoundingClientRect().width + gap;

            track.style.transform = "translateX(" + (-index * step) + "px)";
        }

        nextButton.addEventListener("click", function () {
            index = index >= maxIndex ? 0 : index + 1;
            update();
        });

        prevButton.addEventListener("click", function () {
            index = index <= 0 ? maxIndex : index - 1;
            update();
        });

        window.addEventListener("resize", update);
        update();

    })();
</script>

</body>
</html>
