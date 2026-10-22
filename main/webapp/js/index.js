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
