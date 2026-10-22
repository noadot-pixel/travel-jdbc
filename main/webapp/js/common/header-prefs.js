/*
 * 언어 선택 - data-i18n="키" 가 붙은 요소를 /i18n/{언어}.json에서 찾아 글자를 바꿔친다.
 * 기본값은 일본어. 로그인 여부와 상관없이 모든 페이지에서 동작해야 하므로
 * 알림 벨 스크립트(로그인 시에만 로드)와 분리해서 항상 로드되게 한다.
 *
 * window.i18nDict / window.t()를 같이 공개해두는 이유: 좋아요/스크랩 버튼처럼 클릭한
 * 뒤에 자바스크립트가 직접 글자를 바꿔 끼우는 곳들은 data-i18n이 다시 훑고 지나가지
 * 않으므로, 그런 스크립트들이 번역 사전을 직접 찾아 쓸 수 있게 한다.
 * (각 페이지 스크립트에서: window.t("post.scraped", "스크랩됨") 처럼 사용)
 */

window.i18nDict = {};

window.t = function (key, fallback) {
    return (window.i18nDict && window.i18nDict[key]) || fallback;
};

(function () {

    const select = $("#languageSelect");

    //새로고침/재방문마다 네트워크로 사전을 다시 받아올 때까지 한국어 원문이 잠깐 보였다가
    //번역으로 바뀌는 "깜빡임"이 있었다. localStorage에 사전을 캐시해두고, 있으면 네트워크
    //응답을 기다리지 않고 즉시(동기적으로) 먼저 칠한 뒤, 최신 사전을 받아와 다시 한 번
    //칠한다(파일이 바뀐 경우 대비 - 캐시가 최신이면 결과는 똑같아서 티도 안 난다).
    function readCachedDict(lang) {
        try {
            const cached = localStorage.getItem("i18nDict_" + lang);
            return cached ? JSON.parse(cached) : null;
        } catch (e) {
            return null;
        }
    }

    function writeCachedDict(lang, dict) {
        try {
            localStorage.setItem("i18nDict_" + lang, JSON.stringify(dict));
        } catch (e) {
            // 저장이 안 되면 이번 방문은 매번 네트워크로만 받아온다.
        }
    }

    function applyDict(lang, dict) {

        window.i18nDict = dict;

        $("[data-i18n]").each(function () {

            const key = $(this).data("i18n");
            const attr = $(this).data("i18n-attr");   // 있으면 text 대신 이 속성(예: placeholder)을 바꾼다

            //dict[key]가 falsy인 경우(== "")까지 "번역이 없다"로 취급해버리면, 언어별로
            //일부러 빈 문자열을 쓰는 번역(예: 영어는 호칭 접미사가 없음)이 적용되지 않고
            //한국어 원문이 그대로 남는다. 그래서 "키가 사전에 존재하는가"로 판단한다.
            if (key in dict) {
                if (attr) {
                    $(this).attr(attr, dict[key]);
                } else {
                    $(this).text(dict[key]);
                }
            }

        });

        //SVG 지도처럼 data-i18n 스캔이 못 미치는 동적 콘텐츠용 - 사전이 바뀔 때마다 알려준다.
        $(document).trigger("i18n:applied", [lang, dict]);
    }

    function applyTranslations(lang) {

        const cached = readCachedDict(lang);

        if (cached) {
            applyDict(lang, cached);
        }

        //cache:false로 쿼리스트링을 붙여 브라우저 HTTP 캐시를 우회한다. localStorage 캐시(위)는
        //"깜빡임 방지"를 위해 일부러 남겨두는 것과 별개로, 네트워크 응답 자체가 과거 시점의
        //사전으로 눌러앉아 있으면 아무리 다시 방문해도 최신 번역이 영영 안 들어온다.
        $.ajax({ url: window.contextPath + "/i18n/" + lang + ".json", dataType: "json", cache: false })
            .done(function (dict) {
                writeCachedDict(lang, dict);
                applyDict(lang, dict);
            })
            .fail(function () {
                // 캐시도 없고 네트워크도 실패하면 한국어 원문이 그대로 남는다.
            });

    }

    let lang = "ja";

    try {
        lang = localStorage.getItem("lang") || "ja";
    } catch (e) {
        // 프라이빗 브라우징 등으로 localStorage를 못 쓰면 기본값(일본어)만 보여준다.
    }

    select.val(lang);
    applyTranslations(lang);

    select.on("change", function () {

        const newLang = select.val();

        try {
            localStorage.setItem("lang", newLang);
        } catch (e) {
            // 저장이 안 되면 이번 방문 동안만 선택이 유지된다.
        }

        applyTranslations(newLang);

    });

})();

/*
 * 브랜드 로고 - 언어별로 다른 이미지 파일을 쓴다(한국어/영어는 logo_kr.png,
 * 일본어는 logo_ja.png - 영어 전용 로고는 아직 없어서 당분간 한국어판으로 대신한다).
 * data-i18n-attr 방식은 값을 통째로 바꿔치기만 해서 contextPath/캐시버스터 쿼리스트링을
 * 못 붙이므로, 여기서는 i18n:applied 이벤트를 직접 받아서 src를 조립한다.
 */
(function () {

    const logoVersions = window.headerData.logoVersions;

    function applyLogo(lang, dict) {

        const file = (dict && dict["brand.logoFile"]) || "logo_kr.png";
        const version = logoVersions[file] || Date.now();
        const src = window.contextPath + "/images/" + file + "?v=" + version;

        document.querySelectorAll(".brand-logo-image").forEach(function (img) {
            img.src = src;
        });
    }

    $(document).on("i18n:applied", function (event, lang, dict) {
        applyLogo(lang, dict);
    });

})();

/*
 * 화이트/다크 모드 - 로그인 여부와 상관없이 누구나 쓸 수 있다.
 *
 *   - 로그인 안 한 상태: 서버는 계정이 없어서 항상 "화이트"로 내려준다 - 그래서 페이지가
 *     뜨자마자 로컬스토리지에 저장된 값을 확인해서, "다크"였다면 그 자리에서 바로 바꾼다.
 *   - 로그인한 상태: 서버가 계정에 저장된 값을 이미 정확히 내려줬으므로, 로컬스토리지를
 *     그 값에 맞춰 두기만 한다(나중에 로그아웃해도 마지막으로 쓰던 테마가 유지되게).
 *   - 바꿀 때마다 로컬스토리지에는 항상 저장하고, 로그인 중이면 계정에도 같이 저장한다.
 */

(function () {

    const wrap = document.getElementById("themeSelectWrap");
    const radios = wrap.querySelectorAll('input[name="themeMode"]');
    const labels = wrap.querySelectorAll(".theme-option");
    const isLoggedIn = window.headerData.isLoggedIn;

    function applyTheme(isDark) {

        document.documentElement.setAttribute("data-theme", isDark ? "dark" : "light");

        labels.forEach(function (label) {
            const radio = label.querySelector('input[name="themeMode"]');
            const match = (radio.value === "dark") === isDark;
            label.classList.toggle("active", match);
            radio.checked = match;
        });

    }

    if (!isLoggedIn) {

        let saved = null;

        try {
            saved = localStorage.getItem("theme");
        } catch (e) {
            // 프라이빗 브라우징 등으로 로컬스토리지를 못 쓰면 기본값(화이트)만 보여준다.
        }

        if (saved === "dark") {
            applyTheme(true);
        }

    } else {

        try {
            localStorage.setItem("theme", document.documentElement.getAttribute("data-theme") === "dark" ? "dark" : "light");
        } catch (e) {
            // 저장이 안 돼도 로그인 중엔 서버 값이 기준이라 문제없다.
        }

    }

    radios.forEach(function (radio) {

        radio.addEventListener("change", function () {

            const on = radio.value === "dark";

            applyTheme(on);

            try {
                localStorage.setItem("theme", on ? "dark" : "light");
            } catch (e) {
                // 이번 방문 동안만 유지된다.
            }

            if (!isLoggedIn) {
                return;   // 계정이 없으니 서버에 저장할 것도 없다.
            }

            const body = new URLSearchParams();
            body.set("on", on ? "Y" : "N");

            fetch(window.contextPath + "/member/toggleDarkMode", { method: "POST", body: body })
                .then(function (res) { return res.json(); })
                .then(function (data) {

                    if (data.result !== "ok") {
                        alert(window.t("theme.toggleFailedAlert", "다크모드 설정에 실패했습니다."));
                    }

                });

        });

    });

})();
