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

    long mobileMenuJsVer = new java.io.File(application.getRealPath("/js/common/mobile-menu.js")).lastModified();
    long headerPrefsJsVer = new java.io.File(application.getRealPath("/js/common/header-prefs.js")).lastModified();
    long notificationBellJsVer = new java.io.File(application.getRealPath("/js/common/notification-bell.js")).lastModified();
%>

<script>
    //contextPath를 전역으로 한 번 공개해둔다 - 이 헤더는 모든 페이지에 포함되고, 항상
    //다른 스크립트보다 먼저 로드되므로, js/ 밑으로 뺀 외부 스크립트들이 각 JSP마다
    //따로 인라인 부트스트랩 스크립트를 안 만들어도 window.contextPath로 바로 쓸 수 있다.
    window.contextPath = "<%= contextPath %>";

    //header-prefs.js(로고/다크모드)가 필요로 하는 서버 데이터 - 로고 파일별 캐시버스터
    //버전과 로그인 여부. 둘 다 세션/파일시각 기반이라 JS 파일 자체에는 못 넣는다.
    window.headerData = {
        logoVersions: {
            "logo_kr.png": "<%= headerLogoKrVer %>",
            "logo_ja.png": "<%= headerLogoJaVer %>",
            "logo_en.png": "<%= headerLogoEnVer %>"
        },
        isLoggedIn: <%= headerMember != null %>
    };
</script>

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

                <a href="<%= contextPath %>/member/login"
                   class="login-button"
                   data-i18n="nav.login">
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

<script src="<%= contextPath %>/js/common/mobile-menu.js?v=<%= mobileMenuJsVer %>"></script>

<script src="<%= contextPath %>/js/common/header-prefs.js?v=<%= headerPrefsJsVer %>"></script>

<% if (headerMember != null) { %>
<script src="<%= contextPath %>/js/common/notification-bell.js?v=<%= notificationBellJsVer %>"></script>
<% } %>
