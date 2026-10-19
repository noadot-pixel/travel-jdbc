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

    String countryLabel = "JP".equals(country) ? "일본 여행지" : "한국 여행지";
    String countryI18nKey = "JP".equals(country) ? "country.JP" : "country.KR";

    //Cloudflare가 정적 파일(svg)을 기본 4시간 엣지 캐시로 들고 있어서, css-links.jspf와
    //같은 방식으로 파일 수정 시각을 쿼리스트링에 붙여 수정할 때마다 새로 받아오게 한다.
    String mapSvgFile = "JP".equals(country) ? "japan-regions.svg" : "korea-regions.svg";
    long mapSvgVer = new java.io.File(application.getRealPath("/images/maps/" + mapSvgFile)).lastModified();

    //지도가 fetch로 불러와지기 전에도 카드 높이를 미리 잡아둬서(각 지도의 viewBox 비율대로)
    //로딩 중에 레이아웃이 출렁이지 않게 한다.
    String mapAspectRatio = "JP".equals(country) ? "745 / 815" : "550 / 745";

    //지도 색칠용 JSON - {"KR_CAPITAL":12,"KR_GANGWON":3,...} 형태로 JS에 넘긴다
    StringBuilder regionCountsJson = new StringBuilder("{");
    for (int i = 0; i < totalRanking.size(); i++) {
        if (i > 0) regionCountsJson.append(",");
        RegionRankDTO row = totalRanking.get(i);
        regionCountsJson.append("\"").append(row.getRegion()).append("\":").append(row.getPostCount());
    }
    regionCountsJson.append("}");

    String topPostsByRegionJson = (String) request.getAttribute("topPostsByRegionJson");
    if (topPostsByRegionJson == null) topPostsByRegionJson = "{}";
%>

<!DOCTYPE html>
<html lang="ko" <%= (themeMember != null && themeMember.isDarkMode()) ? "data-theme=\"dark\"" : "" %>>

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
                    <div class="region-map-tooltip" id="regionMapTooltip" hidden></div>
                    <div class="region-map-legend" aria-hidden="true">
                        <span class="ranking-map-legend-label" data-i18n="ranking.mapLegendLow">적음</span>
                        <span class="ranking-map-legend-bar"></span>
                        <span class="ranking-map-legend-label" data-i18n="ranking.mapLegendHigh">많음</span>
                    </div>
                    <div class="region-map-zoom-controls">
                        <button type="button" class="region-map-zoom-button" id="regionMapZoomIn" aria-label="확대">+</button>
                        <button type="button" class="region-map-zoom-button" id="regionMapZoomOut" aria-label="축소">−</button>
                        <button type="button" class="region-map-zoom-button region-map-zoom-reset" id="regionMapZoomReset" aria-label="보기 초기화">⟲</button>
                    </div>
                </div>

            </div>

            <div class="ranking-lists-col">

                <div class="ranking-column">

                    <h2 class="ranking-column-title"><span data-i18n="ranking.male">남성 인기 지역</span> - <span data-i18n="<%= countryI18nKey %>"><%= countryLabel %></span></h2>

                    <% if (maleRanking.isEmpty()) { %>
                    <p class="ranking-empty" data-i18n="ranking.empty">아직 집계된 게시글이 없습니다.</p>
                    <% } else { %>
                    <ol class="ranking-list">
                        <% for (int i = 0; i < maleRanking.size(); i++) {
                            RegionRankDTO row = maleRanking.get(i);
                        %>
                        <li class="ranking-item">
                            <a href="<%= contextPath %>/post/list?country=<%= country %>&region=<%= row.getRegion() %>">
                                <span class="ranking-rank">#<%= i + 1 %></span>
                                <span class="ranking-region" data-i18n="region.<%= row.getRegion() %>"><%= EscapeUtil.html(row.getRegionLabel()) %></span>
                                <span class="ranking-count"><%= row.getPostCount() %><span data-i18n="common.countSuffix">개</span></span>
                            </a>
                        </li>
                        <% } %>
                    </ol>
                    <% } %>

                </div>

                <div class="ranking-column">

                    <h2 class="ranking-column-title"><span data-i18n="ranking.female">여성 인기 지역</span> - <span data-i18n="<%= countryI18nKey %>"><%= countryLabel %></span></h2>

                    <% if (femaleRanking.isEmpty()) { %>
                    <p class="ranking-empty" data-i18n="ranking.empty">아직 집계된 게시글이 없습니다.</p>
                    <% } else { %>
                    <ol class="ranking-list">
                        <% for (int i = 0; i < femaleRanking.size(); i++) {
                            RegionRankDTO row = femaleRanking.get(i);
                        %>
                        <li class="ranking-item">
                            <a href="<%= contextPath %>/post/list?country=<%= country %>&region=<%= row.getRegion() %>">
                                <span class="ranking-rank">#<%= i + 1 %></span>
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
    /*
     * 지역별 게시글 분포 지도 - SVG를 fetch해서 그대로 DOM에 끼워 넣은 다음,
     * 지역(<g data-region="...">)마다 게시글 수에 비례해서 --region-fill 색상 변수를
     * 다시 계산해 칠한다 (게시글이 적을수록 연하게, 많을수록 진하게).
     * 지도 쪽 data-region 값(capital/gangwon/.../hokkaido/kanto/...)과 우리 지역 코드
     * (KR_CAPITAL/.../JP_HOKKAIDO/...)를 서로 변환해야 한다 - 국가마다 다른 지도/맵이 쓰인다.
     *
     * 지역에 마우스를 올리면(또는 키보드로 포커스하면) 그 지역 좋아요 상위 3개를
     * 작은 미리보기로 띄우고, 클릭(또는 Enter)하면 리스트 항목을 눌렀을 때와 똑같이
     * /post/list?country=...&region=... 로 이동한다.
     */

    (function () {

        const container = document.getElementById("regionMapContainer");
        const wrap = document.querySelector(".region-map-wrap");
        const tooltip = document.getElementById("regionMapTooltip");
        const zoomInButton = document.getElementById("regionMapZoomIn");
        const zoomOutButton = document.getElementById("regionMapZoomOut");
        const zoomResetButton = document.getElementById("regionMapZoomReset");

        if (!container || !wrap || !tooltip) {
            return;
        }

        const contextPath = "<%= contextPath %>";
        const country = "<%= country %>";
        const regionCounts = <%= regionCountsJson.toString() %>;
        const topPostsByRegion = <%= topPostsByRegionJson %>;

        const koreaRegionCodeMap = {
            capital: "KR_CAPITAL",
            gangwon: "KR_GANGWON",
            chungcheong: "KR_CHUNGCHEONG",
            jeolla: "KR_JEOLLA",
            gyeongsang: "KR_GYEONGSANG",
            jeju: "KR_JEJU"
        };

        const japanRegionCodeMap = {
            hokkaido: "JP_HOKKAIDO",
            tohoku: "JP_TOHOKU",
            kanto: "JP_KANTO",
            chubu: "JP_CHUBU",
            kinki: "JP_KANSAI",
            chugoku: "JP_CHUGOKU",
            shikoku: "JP_SHIKOKU",
            kyushu: "JP_KYUSHU_OKINAWA"
        };

        const regionCodeMap = country === "JP" ? japanRegionCodeMap : koreaRegionCodeMap;

        const counts = Object.values(regionCodeMap).map(function (code) {
            return regionCounts[code] || 0;
        });

        const min = Math.min.apply(null, counts);
        const max = Math.max.apply(null, counts);

        function colorFor(count) {

            if (max === min) {
                return "hsl(215, 60%, 85%)";
            }

            const t = (count - min) / (max - min);   // 0(가장 적음) ~ 1(가장 많음)
            const lightness = 88 - t * 45;            // 88%(연함) ~ 43%(진함)

            return "hsl(215, 62%, " + lightness.toFixed(0) + "%)";
        }

        function escapeHtml(str) {
            const div = document.createElement("div");
            div.textContent = str == null ? "" : str;
            return div.innerHTML;
        }

        function renderTooltip(regionCode, label) {

            const posts = topPostsByRegion[regionCode] || [];

            if (posts.length === 0) {
                tooltip.innerHTML =
                    '<p class="region-map-tooltip-title">' + escapeHtml(label) + '</p>'
                    + '<p class="region-map-tooltip-empty">' + escapeHtml(window.t("ranking.mapTooltipEmpty", "아직 게시글이 없습니다.")) + '</p>';
                return;
            }

            const items = posts.map(function (post) {
                return '<a class="region-map-tooltip-item" href="' + contextPath + '/post/view?bno=' + post.bno + '">'
                    + '<img src="' + contextPath + '/' + post.img + '" alt="">'
                    + '<span>' + escapeHtml(post.title) + '</span>'
                    + '</a>';
            }).join("");

            tooltip.innerHTML =
                '<p class="region-map-tooltip-title">' + escapeHtml(label) + '</p>'
                + '<div class="region-map-tooltip-list">' + items + '</div>';
        }

        function positionTooltip(group) {

            const wrapRect = wrap.getBoundingClientRect();
            const groupRect = group.getBoundingClientRect();

            let left = groupRect.left - wrapRect.left + groupRect.width / 2;
            const top = Math.max(0, groupRect.top - wrapRect.top);

            //카드 밖으로 넘어가지 않게 좌우를 살짝 눌러준다 (툴팁 폭 어림값 220px 기준)
            left = Math.min(Math.max(left, 115), wrapRect.width - 115);

            tooltip.style.left = left + "px";
            tooltip.style.top = top + "px";
        }

        function showTooltip(group, regionCode, label) {
            renderTooltip(regionCode, label);
            tooltip.hidden = false;
            positionTooltip(group);
        }

        function hideTooltip() {
            tooltip.hidden = true;
        }

        /*
         * 확대/드래그 - <svg>의 viewBox를 직접 조작하는 방식(CSS transform이 아니라).
         * scale(1~MAX_SCALE)과 "화면 중심에 보여줄 콘텐츠 좌표"(centerX/Y)만 상태로 들고
         * 있다가, 바뀔 때마다 그 둘로 viewBox 문자열을 다시 계산해서 넣는다.
         */

        const MAX_SCALE = 2.5;
        const DRAG_THRESHOLD = 6;   // 이 거리(px) 이상 움직여야 "드래그"로 보고 클릭(이동) 취소

        let svg = null;
        let scale = 1;
        let baseX = 0, baseY = 0, baseW = 0, baseH = 0;
        let centerX = 0, centerY = 0;
        let dragging = false, dragMoved = false;
        let dragPointerId = null, lastClientX = 0, lastClientY = 0, movedDistance = 0;

        function clampCenter() {

            const visW = baseW / scale;
            const visH = baseH / scale;

            const minX = baseX + visW / 2;
            const maxX = baseX + baseW - visW / 2;
            const minY = baseY + visH / 2;
            const maxY = baseY + baseH - visH / 2;

            centerX = minX > maxX ? (baseX + baseW / 2) : Math.min(maxX, Math.max(minX, centerX));
            centerY = minY > maxY ? (baseY + baseH / 2) : Math.min(maxY, Math.max(minY, centerY));
        }

        function applyViewBox() {

            if (!svg) {
                return;
            }

            const visW = baseW / scale;
            const visH = baseH / scale;

            svg.setAttribute("viewBox", (centerX - visW / 2) + " " + (centerY - visH / 2) + " " + visW + " " + visH);
            container.classList.toggle("is-zoomed", scale > 1.001);
        }

        //rx/ry: 화면(컨테이너) 안에서 확대 중심으로 삼을 비율(0~1). 마우스 휠은 커서 위치,
        //버튼은 항상 중앙(0.5, 0.5)을 기준으로 확대/축소한다.
        function zoomAt(newScale, rx, ry) {

            newScale = Math.min(MAX_SCALE, Math.max(1, newScale));

            const visW = baseW / scale;
            const visH = baseH / scale;
            const pointX = (centerX - visW / 2) + rx * visW;
            const pointY = (centerY - visH / 2) + ry * visH;

            const newVisW = baseW / newScale;
            const newVisH = baseH / newScale;

            centerX = pointX + newVisW * (0.5 - rx);
            centerY = pointY + newVisH * (0.5 - ry);
            scale = newScale;

            clampCenter();
            applyViewBox();
        }

        //모바일에서 지도를 세로로 드래그하면 페이지 스크롤이 먹통되던 문제 때문에 추가함:
        //(1) 확대를 전혀 안 한 상태(scale=1)면 애초에 패닝이 불가능하므로(clampCenter가
        //    중심을 고정값으로 되돌림) 세로 드래그를 그대로 페이지 스크롤로 넘긴다.
        //(2) 확대한 상태여도, 이미 위/아래 끝까지 패닝한 상태에서 같은 방향으로 더 끌면
        //    (centerY가 clampCenter 전후로 거의 안 바뀜) 그 만큼도 페이지 스크롤로 넘긴다.
        //즉 "더 이상 지도가 움직일 수 없는 세로 드래그"는 전부 페이지 스크롤이 가져간다.
        //common.css에 html { scroll-behavior: smooth }가 전역으로 걸려있어서, 옵션 없이
        //scrollBy()를 부르면 매번 "부드럽게 애니메이션"으로 스크롤하려다가 드래그 중
        //다음 pointermove가 바로 또 scrollBy를 불러서 이전 애니메이션을 취소해버린다
        //(그래서 체감상 거의 안 움직이고 1px씩 끊겨 보였음). behavior:"instant"로
        //손가락 움직임만큼 즉시 점프시켜야 자연스럽게 따라온다.
        function scrollPageBy(dyPx) {
            window.scrollBy({ top: -dyPx, left: 0, behavior: "instant" });
        }

        function panBy(dxPx, dyPx) {

            if (scale <= 1.001) {
                scrollPageBy(dyPx);
                return;
            }

            const rect = container.getBoundingClientRect();

            if (rect.width === 0 || rect.height === 0) {
                return;
            }

            const visW = baseW / scale;
            const visH = baseH / scale;
            const beforeY = centerY;

            centerX -= (dxPx / rect.width) * visW;
            centerY -= (dyPx / rect.height) * visH;

            clampCenter();
            applyViewBox();

            if (dyPx !== 0 && Math.abs(centerY - beforeY) < 0.001) {
                scrollPageBy(dyPx);
            }
        }

        function resetView() {
            scale = 1;
            centerX = baseX + baseW / 2;
            centerY = baseY + baseH / 2;
            applyViewBox();
        }

        container.addEventListener("wheel", function (event) {

            if (!svg) {
                return;
            }

            event.preventDefault();

            const rect = container.getBoundingClientRect();
            const rx = (event.clientX - rect.left) / rect.width;
            const ry = (event.clientY - rect.top) / rect.height;
            const factor = event.deltaY < 0 ? 1.18 : 1 / 1.18;

            zoomAt(scale * factor, rx, ry);

        }, { passive: false });

        container.addEventListener("pointerdown", function (event) {

            if (!svg || event.button === 2) {
                return;
            }

            dragging = true;
            dragMoved = false;
            movedDistance = 0;
            dragPointerId = event.pointerId;
            lastClientX = event.clientX;
            lastClientY = event.clientY;

            try { container.setPointerCapture(dragPointerId); } catch (err) { /* 무시 */ }

            container.classList.add("is-dragging");
        });

        container.addEventListener("pointermove", function (event) {

            if (!dragging || event.pointerId !== dragPointerId) {
                return;
            }

            const dx = event.clientX - lastClientX;
            const dy = event.clientY - lastClientY;

            lastClientX = event.clientX;
            lastClientY = event.clientY;

            movedDistance += Math.abs(dx) + Math.abs(dy);

            if (movedDistance > DRAG_THRESHOLD) {

                if (!dragMoved) {
                    hideTooltip();
                }

                dragMoved = true;
                panBy(dx, dy);
            }
        });

        function endDrag(event) {

            if (!dragging || (event && event.pointerId !== dragPointerId)) {
                return;
            }

            dragging = false;
            container.classList.remove("is-dragging");

            if (dragPointerId !== null) {
                try { container.releasePointerCapture(dragPointerId); } catch (err) { /* 무시 */ }
            }

            dragPointerId = null;
            //dragMoved는 여기서 리셋하지 않는다 - 바로 뒤이어 따라오는 click 이벤트가
            //"이건 드래그였지 클릭이 아니다"를 판단할 수 있어야 하기 때문. 다음 pointerdown에서 리셋된다.
        }

        container.addEventListener("pointerup", endDrag);
        container.addEventListener("pointercancel", endDrag);

        if (zoomInButton) {
            zoomInButton.addEventListener("click", function () { zoomAt(scale * 1.3, 0.5, 0.5); });
        }
        if (zoomOutButton) {
            zoomOutButton.addEventListener("click", function () { zoomAt(scale / 1.3, 0.5, 0.5); });
        }
        if (zoomResetButton) {
            zoomResetButton.addEventListener("click", resetView);
        }

        fetch(container.dataset.mapSrc)
            .then(function (res) { return res.text(); })
            .then(function (svgText) {

                container.innerHTML = svgText;

                svg = container.querySelector("svg");

                if (!svg) {
                    return;
                }

                const viewBox = svg.viewBox.baseVal;
                baseX = viewBox.x;
                baseY = viewBox.y;
                baseW = viewBox.width;
                baseH = viewBox.height;
                centerX = baseX + baseW / 2;
                centerY = baseY + baseH / 2;

                function regionLabelFor(regionCode) {
                    return window.t("region." + regionCode, regionCode);
                }

                const groupMetas = [];

                svg.querySelectorAll("[data-region]").forEach(function (group) {

                    const regionCode = regionCodeMap[group.dataset.region];
                    const count = regionCode ? (regionCounts[regionCode] || 0) : 0;
                    const targetUrl = contextPath + "/post/list?country=" + country + "&region=" + regionCode;

                    group.style.setProperty("--region-fill", colorFor(count));
                    group.setAttribute("tabindex", "0");
                    group.setAttribute("role", "link");

                    groupMetas.push({ el: group, regionCode: regionCode, count: count });

                    group.addEventListener("mouseenter", function () { showTooltip(group, regionCode, regionLabelFor(regionCode)); });
                    group.addEventListener("mousemove", function () { positionTooltip(group); });
                    group.addEventListener("mouseleave", hideTooltip);
                    group.addEventListener("focus", function () { showTooltip(group, regionCode, regionLabelFor(regionCode)); });
                    group.addEventListener("blur", hideTooltip);

                    group.addEventListener("click", function (event) {
                        //드래그(확대 상태에서 지도를 끌던 것)가 막 끝난 직후의 클릭이면 이동하지 않는다
                        if (dragMoved) {
                            event.preventDefault();
                            return;
                        }
                        location.href = targetUrl;
                    });
                    group.addEventListener("keydown", function (event) {
                        if (event.key === "Enter" || event.key === " ") {
                            event.preventDefault();
                            location.href = targetUrl;
                        }
                    });

                });

                //지도 안에 박혀있는 지역명·출처 <text>들 - data-i18n 스캔이 못 미치는 영역이라
                //직접 window.t()로 채워 넣는다. 언어를 바꿀 때마다(i18n:applied) 다시 호출된다.
                const labelEls = svg.querySelectorAll(".map-label");
                const attributionEl = svg.querySelector(".map-attribution");

                function translateMapTexts() {

                    groupMetas.forEach(function (meta) {
                        const label = regionLabelFor(meta.regionCode);
                        meta.el.setAttribute("aria-label", label + " " + meta.count + window.t("common.countSuffix", "개"));
                    });

                    labelEls.forEach(function (el) {
                        const regionCode = regionCodeMap[el.dataset.region];
                        if (regionCode) {
                            el.textContent = regionLabelFor(regionCode);
                        }
                    });

                    if (attributionEl) {
                        const key = country === "JP" ? "ranking.mapAttributionJP" : "ranking.mapAttributionKR";
                        attributionEl.textContent = window.t(key, attributionEl.textContent);
                    }
                }

                translateMapTexts();

                $(document).on("i18n:applied", translateMapTexts);

            })
            .catch(function () {
                // 지도를 못 불러오면 그냥 빈 자리로 둔다 (리스트는 이미 위에 보여주고 있어서 치명적이지 않음).
            });

    })();
</script>

</body>
</html>
