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

    //알림 벨 배지 - 공지(안 읽음) + 내 활동 알림(안 읽음) 개수. 로그인했을 때만 조회한다.
    int headerUnreadTotal = 0;

    if (headerMember != null) {
        headerUnreadTotal = new NoticeDAO().countUnread(headerMember.getId())
                           + new NotificationDAO().countUnread(headerMember.getId());
    }
%>

<header class="header">

    <div class="header-inner">

        <a href="<%= contextPath %>/main"
           class="top-logo">

            <img src="<%= contextPath %>/images/logo.png"
                 alt="여행만들기 로고">
        </a>

        <nav class="navigation">

            <a href="<%= contextPath %>/main"
               class="<%= "home".equals(activeNav) ? "active" : "" %>">
                홈
            </a>

             <a href="<%= contextPath %>/post/list">
                커뮤니티
            </a>

            <a href="<%= contextPath %>/post/ranking"
               class="<%= "ranking".equals(activeNav) ? "active" : "" %>">
                랭킹
            </a>

        </nav>

        <div class="member-menu">

            <a href="<%= contextPath %>/post/write"
               class="write-link">
                글쓰기
            </a>

            <% if (headerMember != null) { %>
            <div class="notif-bell-wrap">

                <button type="button"
                        id="notifBellButton"
                        class="notif-bell-button"
                        aria-label="알림">

                    🔔

                    <% if (headerUnreadTotal > 0) { %>
                    <span class="notif-badge"><%= headerUnreadTotal > 99 ? "99+" : String.valueOf(headerUnreadTotal) %></span>
                    <% } %>

                </button>

                <div id="notifDropdown" class="notif-dropdown" hidden>
                    <p class="notif-loading">불러오는 중...</p>
                </div>

            </div>
            <% } %>

            <span id="memberMenu">

            <% if (headerMember == null) { %>

                <a href="<%= contextPath %>/member/login">
                    로그인
                </a>

                <a href="<%= contextPath %>/member/join"
                   class="join-button">
                    회원가입
                </a>

            <% } else { %>

                <% if (headerMember.isAdmin()) { %>
                <a href="<%= contextPath %>/admin/index.jsp">
                    관리자
                </a>
                <% } %>

                <a href="<%= contextPath %>/member/mypage">
                    마이페이지
                </a>

                <span class="member-nickname"><%= EscapeUtil.html(headerMember.getNickname()) %>님</span>

                <a href="<%= contextPath %>/member/logout">
                    로그아웃
                </a>

            <% } %>

            </span>

        </div>

    </div>

</header>

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
                    parts.push(
                        '<a href="<%= contextPath %>/post/view?bno=' + a.bno + '" class="notif-item notif-alert-item' +
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
