<%@ page pageEncoding="UTF-8" %>
<%@ page import="model.MemberDTO" %>
<%@ page import="model.NoticeDAO" %>
<%@ page import="model.NotificationDAO" %>
<%@ page import="util.EscapeUtil" %>
<%--
    공통 헤더. 사용하는 페이지는 include 전에 아래 변수를 선언해야 한다.

        String contextPath = request.getContextPath();
        String activeNav = "home"; // "home" | "posts" | "ranking" | "" (해당 없음)

    이 파일은 include 지시어로 각 페이지에 "코드째로 복사"되어 들어간다
    → 여기서 만든 변수 이름이 페이지의 변수 이름과 겹치면 중복 선언 에러가 나므로
      header 전용 이름(headerXxx)을 쓴다.
--%>
<%
    MemberDTO headerMember = (MemberDTO) session.getAttribute("loginMember");
    String headerCurrentUri = request.getRequestURI();
    boolean headerOnMyPage = headerCurrentUri != null
        && headerCurrentUri.contains("/member/mypage");
    boolean headerOnWritePage = headerCurrentUri != null
        && (headerCurrentUri.contains("/post/write") || headerCurrentUri.contains("/post/modify"));

    //알림 벨 배지 - 공지(안 읽음) + 내 활동 알림(안 읽음) 개수. 로그인했을 때만 조회한다.
    int headerUnreadTotal = 0;

    if (headerMember != null) {
        headerUnreadTotal = new NoticeDAO().countUnread(headerMember.getId())
                           + new NotificationDAO().countUnread(headerMember.getId());
    }

    //브랜드 로고 - 언어별로 다른 이미지 파일(logo_kr.png/logo_ja.png)을 쓴다. css-links.jspf와
    //같은 이유로 Cloudflare 캐시를 피하려고 파일 수정 시각을 쿼리스트링에 붙인다.
    long headerLogoKrVer = new java.io.File(application.getRealPath("/images/logo_kr.png")).lastModified();
    long headerLogoJaVer = new java.io.File(application.getRealPath("/images/logo_ja.png")).lastModified();
    long headerLogoEnVer = new java.io.File(application.getRealPath("/images/logo_en.png")).lastModified();
%>

<header class="header" id="siteHeader">

    <div class="header-inner">

        <a href="<%= contextPath %>/main"
           class="top-logo">

            <img src="<%= contextPath %>/images/logo_ja.png?v=<%= headerLogoJaVer %>"
                 alt="여행만들기 로고"
                 class="brand-logo-image"
                 data-i18n="brand.logoAlt"
                 data-i18n-attr="alt">
        </a>

        <button type="button"
                class="mobile-menu-toggle"
                id="mobileMenuToggle"
                aria-controls="mobileMenuPanel"
                aria-expanded="false">
            <span class="blind" data-i18n="nav.menuOpen">메뉴 열기</span>
            <span aria-hidden="true"></span>
            <span aria-hidden="true"></span>
            <span aria-hidden="true"></span>
        </button>

        <div class="header-menu-panel" id="mobileMenuPanel">

        <nav class="navigation" data-i18n="nav.mainMenuAriaLabel" data-i18n-attr="aria-label" aria-label="주요 메뉴">

            <a href="<%= contextPath %>/main"
               class="<%= "home".equals(activeNav) ? "active" : "" %>"
               data-i18n="nav.home">
                홈
            </a>

             <a href="<%= contextPath %>/post/list"
                class="<%= "posts".equals(activeNav) && !headerOnWritePage ? "active" : "" %>"
                data-i18n="nav.community">
                커뮤니티
            </a>

            <a href="<%= contextPath %>/post/ranking"
               class="<%= "ranking".equals(activeNav) ? "active" : "" %>"
               data-i18n="nav.ranking">
                랭킹
            </a>

        </nav>

        <div class="header-preferences">

        <div class="lang-select-wrap">
            <label for="languageSelect" class="blind" data-i18n="lang.selectLabel">언어 선택</label>
            <select id="languageSelect">
                <option value="ja">日本語</option>
                <option value="en">English</option>
                <option value="ko">한국어</option>
            </select>
        </div>

        </div>

        <div class="member-menu">

            <%-- 로그인 여부와 상관없이 누구나 쓸 수 있다. 로그인했으면 서버가 계정의 다크모드
                 값을 그대로 내려주고(아래 체크 상태), 로그인 안 했으면 일단 "화이트"로 내려준 뒤
                 아래 스크립트가 로컬스토리지 값을 보고 그 자리에서 바로 고쳐 적용한다.
                 오른쪽(글쓰기 바로 앞) 기준으로 붙여둔다 - member-menu가 margin-left:auto라
                 여기 들어간 요소는 전부 오른쪽 끝에서부터 자리를 잡는다. --%>
            <div class="theme-select-wrap" id="themeSelectWrap">

                <label class="theme-option <%= (headerMember == null || !headerMember.isDarkMode()) ? "active" : "" %>">
                    <input type="radio" name="themeMode" value="light" <%= (headerMember == null || !headerMember.isDarkMode()) ? "checked" : "" %>>
                    <span data-i18n="theme.light">화이트</span>
                </label>

                <label class="theme-option <%= (headerMember != null && headerMember.isDarkMode()) ? "active" : "" %>">
                    <input type="radio" name="themeMode" value="dark" <%= (headerMember != null && headerMember.isDarkMode()) ? "checked" : "" %>>
                    <span data-i18n="theme.dark">다크</span>
                </label>

            </div>

            <a href="<%= contextPath %>/post/write"
               class="write-link"
               data-i18n="nav.write">
                글쓰기
            </a>

            <% if (headerMember != null) { %>
            <div class="notif-bell-wrap">

                <button type="button"
                        id="notifBellButton"
                        class="notif-bell-button"
                        data-i18n="notif.bellAriaLabel"
                        data-i18n-attr="aria-label"
                        aria-label="알림">

                    🔔

                    <% if (headerUnreadTotal > 0) { %>
                    <span class="notif-badge"><%= headerUnreadTotal > 99 ? "99+" : String.valueOf(headerUnreadTotal) %></span>
                    <% } %>

                </button>

                <div id="notifDropdown" class="notif-dropdown" hidden>
                    <p class="notif-loading" data-i18n="notif.loading">불러오는 중...</p>
                </div>

            </div>
            <% } %>

            <span id="memberMenu">

            <% if (headerMember == null) { %>

                <a href="<%= contextPath %>/member/login" data-i18n="nav.login">
                    로그인
                </a>

                <a href="<%= contextPath %>/member/join"
                   class="join-button"
                   data-i18n="nav.join">
                    회원가입
                </a>

            <% } else { %>

                <% if (headerMember.isModerator()) { %>
                <a href="<%= contextPath %>/admin" data-i18n="nav.admin">
                    관리자
                </a>
                <% } %>

                <a href="<%= contextPath %>/member/mypage" data-i18n="nav.mypage">
                    마이페이지
                </a>

                <span class="member-nickname"><%= EscapeUtil.html(headerMember.getNickname()) %><span data-i18n="common.honorific">님</span></span>

                <a href="<%= contextPath %>/member/logout" data-i18n="nav.logout">
                    로그아웃
                </a>

            <% } %>

            </span>

        </div>

        </div>

    </div>

</header>

<button type="button"
        class="mobile-menu-backdrop"
        id="mobileMenuBackdrop"
        data-i18n="nav.menuClose"
        data-i18n-attr="aria-label"
        aria-label="메뉴 닫기"
        hidden></button>

<nav class="mobile-bottom-nav" data-i18n="nav.mobileBottomNavAriaLabel" data-i18n-attr="aria-label" aria-label="모바일 빠른 메뉴">
    <a href="<%= contextPath %>/main"
       class="mobile-bottom-nav-item <%= "home".equals(activeNav) ? "active" : "" %>"
       <%= "home".equals(activeNav) ? "aria-current=\"page\"" : "" %>>
        <span class="mobile-bottom-nav-icon" aria-hidden="true">⌂</span>
        <span data-i18n="nav.home">홈</span>
    </a>
    <a href="<%= contextPath %>/post/list"
       class="mobile-bottom-nav-item <%= "posts".equals(activeNav) && !headerOnWritePage ? "active" : "" %>"
       <%= "posts".equals(activeNav) && !headerOnWritePage ? "aria-current=\"page\"" : "" %>>
        <span class="mobile-bottom-nav-icon" aria-hidden="true">⌕</span>
        <span data-i18n="nav.community">커뮤니티</span>
    </a>
    <a href="<%= contextPath %>/post/write"
       class="mobile-bottom-nav-item mobile-bottom-nav-write <%= headerOnWritePage ? "active" : "" %>"
       <%= headerOnWritePage ? "aria-current=\"page\"" : "" %>>
        <span class="mobile-bottom-nav-write-icon" aria-hidden="true">+</span>
        <span data-i18n="nav.write">글쓰기</span>
    </a>
    <a href="<%= contextPath %>/post/ranking"
       class="mobile-bottom-nav-item <%= "ranking".equals(activeNav) ? "active" : "" %>"
       <%= "ranking".equals(activeNav) ? "aria-current=\"page\"" : "" %>>
        <span class="mobile-bottom-nav-icon" aria-hidden="true">♕</span>
        <span data-i18n="nav.ranking">랭킹</span>
    </a>
    <a href="<%= headerMember != null ? contextPath + "/member/mypage" : contextPath + "/member/login" %>"
       class="mobile-bottom-nav-item <%= headerOnMyPage ? "active" : "" %>"
       <%= headerOnMyPage ? "aria-current=\"page\"" : "" %>>
        <span class="mobile-bottom-nav-icon" aria-hidden="true">♙</span>
        <% if (headerMember == null) { %>
        <span data-i18n="nav.login">로그인</span>
        <% } else { %>
        <span data-i18n="nav.mypage">내 정보</span>
        <% } %>
    </a>
</nav>

<% if (headerMember != null && headerMember.isSuspended()) { %>
<div class="suspended-banner" data-i18n="banner.suspended">
    활동이 정지된 계정입니다. 댓글·좋아요·글쓰기를 할 수 없습니다.
</div>
<% } %>

<script>
    /* 휴대폰에서는 데스크톱 메뉴를 오른쪽 드로어로 전환한다. */
    (function () {

        const header = document.getElementById("siteHeader");
        const toggle = document.getElementById("mobileMenuToggle");
        const backdrop = document.getElementById("mobileMenuBackdrop");
        const panel = document.getElementById("mobileMenuPanel");
        const toggleLabel = toggle && toggle.querySelector(".blind");

        if (!header || !toggle || !backdrop || !panel) {
            return;
        }

        function setMenuOpen(open, options) {
            const mobileViewport = window.innerWidth <= 1024;
            const shouldOpen = mobileViewport && open;

            header.classList.toggle("mobile-menu-open", shouldOpen);
            document.body.classList.toggle("mobile-menu-open", shouldOpen);
            toggle.setAttribute("aria-expanded", String(shouldOpen));
            backdrop.hidden = !shouldOpen;
            panel.inert = mobileViewport && !shouldOpen;

            if (toggleLabel) {
                toggleLabel.textContent = shouldOpen
                    ? window.t("nav.menuClose", "메뉴 닫기")
                    : window.t("nav.menuOpen", "메뉴 열기");
            }

            if (mobileViewport) {
                panel.setAttribute("aria-hidden", String(!shouldOpen));
            } else {
                panel.removeAttribute("aria-hidden");
            }

            if (shouldOpen && options && options.focusDrawer) {
                window.setTimeout(function () {
                    const firstControl = panel.querySelector("a[href], button:not([disabled]), select, input:not([disabled])");
                    if (firstControl) {
                        firstControl.focus();
                    }
                }, 0);
            }

            if (!shouldOpen && options && options.returnFocus) {
                toggle.focus();
            }
        }

        toggle.addEventListener("click", function () {
            setMenuOpen(!header.classList.contains("mobile-menu-open"), { focusDrawer: true });
        });

        backdrop.addEventListener("click", function () {
            setMenuOpen(false, { returnFocus: true });
        });

        panel.querySelectorAll("a").forEach(function (link) {
            link.addEventListener("click", function () {
                if (window.innerWidth <= 1024) {
                    setMenuOpen(false);
                }
            });
        });

        document.addEventListener("keydown", function (event) {
            if (event.key === "Escape" && header.classList.contains("mobile-menu-open")) {
                setMenuOpen(false, { returnFocus: true });
                return;
            }

            if (event.key !== "Tab" || !header.classList.contains("mobile-menu-open")) {
                return;
            }

            const focusable = Array.prototype.slice.call(
                panel.querySelectorAll("a[href], button:not([disabled]), select, input:not([disabled])")
            ).filter(function (element) {
                return !element.hidden && element.getClientRects().length > 0;
            });

            if (focusable.length === 0) {
                return;
            }

            const first = focusable[0];
            const last = focusable[focusable.length - 1];

            if (event.shiftKey && document.activeElement === first) {
                event.preventDefault();
                last.focus();
            } else if (!event.shiftKey && document.activeElement === last) {
                event.preventDefault();
                first.focus();
            }
        });

        //뷰포트 폭이 바뀔 때마다(모바일<->PC 양쪽 방향 다) 열림 상태를 다시 계산한다.
        //예전엔 "열려있을 때 PC 폭으로 커지는" 경우만 처리했는데, 그러면 모바일 폭에서
        //드로어를 한 번도 안 열고 그대로 PC 폭으로 키웠을 때 panel.inert가 true로 남아서
        //데스크톱 메뉴 전체가 클릭·포커스가 전혀 안 먹는 상태로 고정되는 문제가 있었다.
        window.addEventListener("resize", function () {
            setMenuOpen(header.classList.contains("mobile-menu-open"));
        });

        setMenuOpen(false);

    })();
</script>

<script>
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

            $.getJSON("<%= contextPath %>/i18n/" + lang + ".json")
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

        const contextPath = "<%= contextPath %>";
        const logoVersions = {
            "logo_kr.png": "<%= headerLogoKrVer %>",
            "logo_ja.png": "<%= headerLogoJaVer %>",
            "logo_en.png": "<%= headerLogoEnVer %>"
        };

        function applyLogo(lang, dict) {

            const file = (dict && dict["brand.logoFile"]) || "logo_kr.png";
            const version = logoVersions[file] || Date.now();
            const src = contextPath + "/images/" + file + "?v=" + version;

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
        const isLoggedIn = <%= headerMember != null %>;

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

                fetch("<%= contextPath %>/member/toggleDarkMode", { method: "POST", body: body })
                    .then(function (res) { return res.json(); })
                    .then(function (data) {

                        if (data.result !== "ok") {
                            alert(window.t("theme.toggleFailedAlert", "다크모드 설정에 실패했습니다."));
                        }

                    });

            });

        });

    })();
</script>

<% if (headerMember != null) { %>
<script>
    /*
     * 알림 벨 - 클릭하면 공지 최신 5개 + 내 활동 알림(댓글/좋아요) 최신 10개를 불러와 보여주고,
     * 서버에서 그 자리에 전부 읽음 처리한다(다음에 열 때 배지가 0부터 다시 쌓임).
     */

    (function () {

        const button = document.getElementById("notifBellButton");
        const dropdown = document.getElementById("notifDropdown");
        const badge = button.querySelector(".notif-badge");

        let loaded = false;

        function escapeHtml(str) {
            const div = document.createElement("div");
            div.textContent = str;
            return div.innerHTML;
        }

        function render(data) {

            const parts = [];

            if (data.notices.length > 0) {
                parts.push('<p class="notif-section-title">공지</p>');
                data.notices.forEach(function (n) {
                    parts.push(
                        '<a href="<%= contextPath %>/notice/view?noticeId=' + n.noticeId + '" ' +
                            'class="notif-item notif-notice-item" title="' + escapeHtml(n.content) + '">' +
                            '<strong>' + escapeHtml(n.title) + '</strong>' +
                            '<span>' + escapeHtml(n.regDate) + '</span>' +
                        '</a>'
                    );
                });
            }

            if (data.alerts.length > 0) {
                parts.push('<p class="notif-section-title">내 알림</p>');
                data.alerts.forEach(function (a) {
                    const href = a.targetType === "INQUIRY"
                        ? "<%= contextPath %>/support/view?inquiryId=" + a.inquiryId
                        : "<%= contextPath %>/post/view?bno=" + a.bno;
                    parts.push(
                        '<a href="' + href + '" class="notif-item notif-alert-item' +
                            (a.read ? '' : ' notif-unread') + '">' +
                            '<span>' + escapeHtml(a.message) + '</span>' +
                            '<span>' + escapeHtml(a.regDate) + '</span>' +
                        '</a>'
                    );
                });
            }

            if (parts.length === 0) {
                parts.push('<p class="notif-empty">새 소식이 없습니다.</p>');
            }

            dropdown.innerHTML = parts.join("");
        }

        button.addEventListener("click", function (event) {

            event.stopPropagation();

            dropdown.hidden = !dropdown.hidden;

            if (dropdown.hidden || loaded) {
                return;
            }

            fetch("<%= contextPath %>/notification/list")
                .then(function (res) { return res.json(); })
                .then(function (data) {

                    if (data.result !== "ok") {
                        return;
                    }

                    loaded = true;
                    render(data);

                    if (badge) {
                        badge.remove();
                    }

                });

        });

        document.addEventListener("click", function (event) {
            if (!dropdown.hidden && !dropdown.contains(event.target) && event.target !== button) {
                dropdown.hidden = true;
            }
        });

    })();
</script>
<% } %>
