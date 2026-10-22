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

    const contextPath = window.contextPath;
    const country = window.rankingData.country;
    //전체/남성/여성 세 버전을 다 들고 있다가, 라디오를 바꾸면 그 자리에서 다시 칠한다.
    const regionCountsByGender = window.rankingData.regionCounts;
    let activeGender = "all";
    const topPostsByRegion = window.rankingData.topPostsByRegion;

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

    let min = 0, max = 0;

    //라디오(전체/남성/여성)를 바꿀 때마다, 그 데이터셋 기준으로 min/max를 다시 잡는다
    //(예: 남성 데이터는 지역별 수치 범위가 전체 데이터와 다르므로 색 대비도 다시 계산해야 한다).
    function recomputeMinMax() {

        const activeCounts = regionCountsByGender[activeGender] || {};

        const values = Object.values(regionCodeMap).map(function (code) {
            return activeCounts[code] || 0;
        });

        min = Math.min.apply(null, values);
        max = Math.max.apply(null, values);
    }

    recomputeMinMax();

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
    let startClientX = 0, startClientY = 0;
    let downRegionGroup = null;   // pointerdown이 눌린 지역(<g data-region>) - 탭 판정되면 이쪽으로 이동시킨다

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
        startClientX = event.clientX;
        startClientY = event.clientY;
        downRegionGroup = event.target.closest ? event.target.closest("[data-region]") : null;

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

        //pointerdown 때의 시작 위치에서 지금까지 순이동 거리로 재야 한다. 터치스크린은
        //손가락을 가만히 대고 있어도 센서 떨림 때문에 pointermove가 여러 번 발생하는데,
        //그 "조금씩의 이동"을 매번 절대값으로 누적하면(이전 코드) 실제로는 거의 안 움직인
        //탭에서도 금방 DRAG_THRESHOLD를 넘어버려서 dragMoved가 잘못 true가 됐다.
        //그러면 바로 뒤에 오는 click 이벤트가 "이건 드래그였다"고 오판해 이동을 막아버리고
        //(그런데 키보드 Enter 핸들러는 dragMoved를 아예 안 보므로 그쪽만 정상 동작했다),
        //모바일에서 "지역을 탭해도 안 움직이고 Enter를 눌러야만 이동한다"는 증상으로
        //이어졌다.
        movedDistance = Math.abs(event.clientX - startClientX) + Math.abs(event.clientY - startClientY);

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

        //탭(드래그가 아닌 짧은 터치)이었는지는 여기서 바로 판정하고 이동도 여기서
        //직접 시킨다 - pointerup 뒤에 브라우저가 합성해서 쏘는 click 이벤트에 맡기지
        //않는다. setPointerCapture로 포인터를 잡아둔 상태(모바일 터치 패닝을 직접
        //구현하려면 필수)에서는, 그 뒤에 나가는 click 이벤트가 원래 눌렀던
        //<g data-region> 요소가 아니라 캡처 주체인 container 쪽으로 다시 타겟팅되거나
        //아예 발생하지 않는 경우가 실제로 있었다 - 모바일에서만 "지역을 탭해도 안
        //움직이고, 포커스가 이미 잡힌 뒤 키보드 Enter를 눌러야만(click을 아예 거치지
        //않으므로) 이동되던 증상의 진짜 원인이 이쪽이었다.
        const navUrl = event && event.type === "pointerup" && !dragMoved && downRegionGroup
            ? downRegionGroup.dataset.navUrl
            : null;

        dragging = false;
        container.classList.remove("is-dragging");

        if (dragPointerId !== null) {
            try { container.releasePointerCapture(dragPointerId); } catch (err) { /* 무시 */ }
        }

        dragPointerId = null;
        downRegionGroup = null;

        if (navUrl) {
            location.href = navUrl;
        }
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

            function countFor(regionCode) {
                const activeCounts = regionCountsByGender[activeGender] || {};
                return regionCode ? (activeCounts[regionCode] || 0) : 0;
            }

            svg.querySelectorAll("[data-region]").forEach(function (group) {

                const regionCode = regionCodeMap[group.dataset.region];
                const count = countFor(regionCode);
                const targetUrl = contextPath + "/post/list?country=" + country + "&region=" + regionCode;

                group.style.setProperty("--region-fill", colorFor(count));
                group.setAttribute("tabindex", "0");
                group.setAttribute("role", "link");
                group.dataset.navUrl = targetUrl;   // endDrag(pointerup)에서 탭 판정되면 이 값으로 이동한다

                groupMetas.push({ el: group, regionCode: regionCode, count: count });

                group.addEventListener("mouseenter", function () { showTooltip(group, regionCode, regionLabelFor(regionCode)); });
                group.addEventListener("mousemove", function () { positionTooltip(group); });
                group.addEventListener("mouseleave", hideTooltip);
                group.addEventListener("focus", function () { showTooltip(group, regionCode, regionLabelFor(regionCode)); });
                group.addEventListener("blur", hideTooltip);

                //이동은 pointerup(endDrag)에서 직접 처리한다 - 아래 주석 참고.
                //여기엔 네이티브 click 리스너를 달지 않는다.
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

            //지도 우측 상단 전체/남성/여성 라디오 - 바꾸면 그 데이터셋 기준으로 min/max부터
            //다시 잡고(recomputeMinMax), 모든 지역의 색과 aria-label을 새로 칠한다.
            function repaintMap() {

                recomputeMinMax();

                groupMetas.forEach(function (meta) {
                    meta.count = countFor(meta.regionCode);
                    meta.el.style.setProperty("--region-fill", colorFor(meta.count));
                });

                translateMapTexts();
            }

            document.querySelectorAll('#regionMapGenderFilter input[name="regionMapGender"]').forEach(function (radio) {

                radio.addEventListener("change", function () {

                    activeGender = radio.value;

                    document.querySelectorAll("#regionMapGenderFilter .theme-option").forEach(function (label) {
                        label.classList.toggle("active", label.querySelector("input").checked);
                    });

                    hideTooltip();
                    repaintMap();

                });

            });

        })
        .catch(function () {
            // 지도를 못 불러오면 그냥 빈 자리로 둔다 (리스트는 이미 위에 보여주고 있어서 치명적이지 않음).
        });

})();
