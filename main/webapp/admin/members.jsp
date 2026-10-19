<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%@ page import="java.util.List" %>
<%@ page import="model.MemberDTO" %>
<%@ page import="util.EscapeUtil" %>

<%
    String contextPath = request.getContextPath();

    MemberDTO loginMember = (MemberDTO) session.getAttribute("loginMember");

    if (loginMember == null) {
        response.sendRedirect(contextPath + "/member/login");
        return;
    }

    if (!loginMember.isModerator()) {
        response.sendRedirect(contextPath + "/main");
        return;
    }

    //이 페이지는 반드시 MemberListCommand(/admin/members)를 거쳐서 와야 한다.
    List<MemberDTO> memberList = (List<MemberDTO>) request.getAttribute("memberList");

    if (memberList == null) {
        response.sendRedirect(contextPath + "/admin/members");
        return;
    }
%>

<!DOCTYPE html>
<html lang="ko" <%= (loginMember != null && loginMember.isDarkMode()) ? "data-theme=\"dark\"" : "" %>>

<head>
    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>회원 관리 - 여행만들기</title>

    <%@ include file="/common/css-links.jspf" %>
</head>

<body>

<% String activeNav = ""; %>
<%@ include file="/common/header.jsp" %>

<main>

    <section class="page-heading">

        <p class="breadcrumb">
            <a href="<%= contextPath %>/main" data-i18n="nav.home">홈</a>
            〉 <a href="<%= contextPath %>/admin" data-i18n="nav.admin">관리자</a>
            〉 <span data-i18n="admin.menuMembersTitle">회원 관리</span>
        </p>

        <h1 data-i18n="admin.menuMembersTitle">회원 관리</h1>

        <p class="page-description" data-i18n="adminMembers.pageDesc">
            활동 정지된 계정은 댓글·좋아요·글쓰기를 할 수 없습니다 (스크랩은 가능).
            모더레이터 이상 계정과 본인 계정은 정지할 수 없습니다.
            권한 레벨 변경은 관리자만 할 수 있습니다.
        </p>

    </section>

    <section class="admin-member-list-section">

        <table class="admin-member-table">

            <thead>
                <tr>
                    <th data-i18n="adminMembers.colNickname">닉네임</th>
                    <th data-i18n="adminMembers.colEmail">이메일</th>
                    <th data-i18n="adminMembers.colJoinDate">가입일</th>
                    <th data-i18n="adminMembers.colLevel">구분</th>
                    <th data-i18n="adminMembers.colStatus">상태</th>
                    <th></th>
                </tr>
            </thead>

            <tbody>
                <% for (MemberDTO member : memberList) { %>
                <tr data-member-id="<%= EscapeUtil.html(member.getId()) %>">

                    <td>
                        <a href="<%= contextPath %>/member/profile?id=<%= member.getId() %>">
                            <%= EscapeUtil.html(member.getNickname()) %>
                        </a>
                    </td>

                    <td><%= EscapeUtil.html(member.getId()) %></td>

                    <td><%= member.getJoinDate() %></td>

                    <td>
                        <%
                            String levelLabel;
                            String levelI18nKey;
                            if (member.getAdminLevel() == 2) { levelLabel = "관리자"; levelI18nKey = "nav.admin"; }
                            else if (member.getAdminLevel() == 1) { levelLabel = "모더레이터"; levelI18nKey = "adminMembers.levelModerator"; }
                            else { levelLabel = "일반"; levelI18nKey = "adminMembers.levelMember"; }
                        %>
                        <span data-i18n="<%= levelI18nKey %>"><%= levelLabel %></span>
                    </td>

                    <td>
                        <span class="admin-member-status <%= member.isSuspended() ? "suspended" : "" %>" data-i18n="<%= member.isSuspended() ? "adminMembers.statusSuspended" : "adminMembers.statusNormal" %>">
                            <%= member.isSuspended() ? "정지됨" : "정상" %>
                        </span>
                    </td>

                    <td>
                        <div class="admin-member-actions">
                        <% if (member.getId().equals(loginMember.getId())) { %>
                        <span class="admin-member-no-action" data-i18n="adminMembers.selfAccount">본인 계정</span>
                        <% } else { %>

                            <% if (loginMember.isAdmin()) { %>
                            <select class="admin-member-level-select" data-current="<%= member.getAdminLevel() %>">
                                <option value="0" data-i18n="adminMembers.levelMemberFull" <%= member.getAdminLevel() == 0 ? "selected" : "" %>>일반회원</option>
                                <option value="1" data-i18n="adminMembers.levelModerator" <%= member.getAdminLevel() == 1 ? "selected" : "" %>>모더레이터</option>
                                <option value="2" data-i18n="nav.admin" <%= member.getAdminLevel() == 2 ? "selected" : "" %>>관리자</option>
                            </select>
                            <% } %>

                            <% if (!member.isModerator()) { %>
                                <% if (member.isSuspended()) { %>
                                <button type="button" class="admin-member-unsuspend-button" data-i18n="adminMembers.unsuspend">정지 해제</button>
                                <% } else { %>
                                <button type="button" class="admin-member-suspend-button" data-i18n="adminMembers.suspend">활동 정지</button>
                                <% } %>
                            <% } %>

                        <% } %>
                        </div>
                    </td>

                </tr>
                <% } %>
            </tbody>

        </table>

    </section>

</main>

<%@ include file="/common/footer.jsp" %>

<script>
    function toggleSuspend(row, suspend) {

        const id = row.dataset.memberId;

        const body = new URLSearchParams();
        body.set("id", id);
        body.set("suspend", suspend ? "Y" : "N");

        fetch("<%= contextPath %>/admin/members/suspend", { method: "POST", body: body })
            .then(function (res) { return res.json(); })
            .then(function (data) {

                if (data.result === "self") {
                    alert(window.t("adminMembers.cannotSuspendSelf", "본인 계정은 정지할 수 없습니다."));
                    return;
                }

                if (data.result === "admin") {
                    alert(window.t("adminMembers.cannotSuspendModerator", "모더레이터 이상 계정은 정지할 수 없습니다."));
                    return;
                }

                if (data.result !== "ok") {
                    alert(window.t("adminMembers.actionFailed", "처리에 실패했습니다."));
                    return;
                }

                location.reload();
            });

    }

    document.querySelectorAll(".admin-member-suspend-button").forEach(function (button) {

        button.addEventListener("click", function () {

            const row = button.closest("tr");

            if (!confirm(row.querySelector("td a").textContent.trim() + window.t("adminMembers.confirmSuspend", "님을 활동 정지시킬까요?"))) {
                return;
            }

            toggleSuspend(row, true);

        });

    });

    document.querySelectorAll(".admin-member-unsuspend-button").forEach(function (button) {

        button.addEventListener("click", function () {
            toggleSuspend(button.closest("tr"), false);
        });

    });

    function levelLabel(level) {
        if (level === "2") return window.t("nav.admin", "관리자");
        if (level === "1") return window.t("adminMembers.levelModerator", "모더레이터");
        return window.t("adminMembers.levelMemberFull", "일반회원");
    }

    document.querySelectorAll(".admin-member-level-select").forEach(function (select) {

        select.addEventListener("change", function () {

            const row = select.closest("tr");
            const id = row.dataset.memberId;
            const nickname = row.querySelector("td a").textContent.trim();
            const newLevel = select.value;

            if (!confirm(nickname + window.t("adminMembers.confirmLevelChangePrefix", "님의 권한을 \"") + levelLabel(newLevel) + window.t("adminMembers.confirmLevelChangeSuffix", "\"(으)로 바꿀까요?"))) {
                select.value = select.dataset.current;
                return;
            }

            const body = new URLSearchParams();
            body.set("id", id);
            body.set("level", newLevel);

            fetch("<%= contextPath %>/admin/members/setLevel", { method: "POST", body: body })
                .then(function (res) { return res.json(); })
                .then(function (data) {

                    if (data.result === "self") {
                        alert(window.t("adminMembers.cannotChangeSelfLevel", "본인 계정은 여기서 바꿀 수 없습니다."));
                        select.value = select.dataset.current;
                        return;
                    }

                    if (data.result === "forbidden") {
                        alert(window.t("adminMembers.levelChangeForbidden", "권한 레벨 변경은 관리자만 할 수 있습니다."));
                        select.value = select.dataset.current;
                        return;
                    }

                    if (data.result !== "ok") {
                        alert(window.t("adminMembers.actionFailed", "처리에 실패했습니다."));
                        select.value = select.dataset.current;
                        return;
                    }

                    location.reload();
                });

        });

    });
</script>

</body>
</html>
