/*
 * 브라우저 탭 제목(document.title) - 게시글 제목/공지 제목/닉네임처럼 실제 데이터가
 * 섞여 들어가는 페이지는 data-i18n 하나로 통째로 바꿔치기할 수 없어서(값이 서버마다
 * 다름), 이 스크립트가 따로 조립한다.
 *
 * 각 페이지는 이 스크립트를 로드하기 전에 window.pageTitleData를 선언해야 한다.
 *   content      - 번역되지 않는 실제 내용(게시글 제목 등)
 *   suffixKey    - (선택) content 바로 뒤에 붙는 i18n 키 (예: "...님의 프로필")
 *   suffixFallback - suffixKey가 사전에 없을 때 쓸 한국어 원문
 *
 * 최종 형태: {content}{suffix 번역} - {브랜드명 번역}
 * header-prefs.js가 이미 채워둔 window.i18nDict를 그대로 읽고, 언어가 바뀔 때마다
 * (i18n:applied) 다시 조립한다.
 */
(function () {

    const data = window.pageTitleData;

    if (!data || !data.content) {
        return;
    }

    function apply() {

        const dict = window.i18nDict || {};
        const brand = dict["home.footerVisual.webTitle"] || "여행만들기";
        const suffix = data.suffixKey
            ? (dict[data.suffixKey] || data.suffixFallback || "")
            : "";

        document.title = data.content + suffix + " - " + brand;
    }

    apply();
    $(document).on("i18n:applied", apply);

})();
