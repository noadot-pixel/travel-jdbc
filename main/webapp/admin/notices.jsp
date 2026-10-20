<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%@ page import="java.util.List" %>
<%@ page import="model.MemberDTO" %>
<%@ page import="model.NoticeDTO" %>
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

    //이 페이지는 반드시 NoticeListCommand(/admin/notices)를 거쳐서 와야 한다.
    List<NoticeDTO> noticeList = (List<NoticeDTO>) request.getAttribute("noticeList");

    if (noticeList == null) {
        response.sendRedirect(contextPath + "/admin/notices");
        return;
    }
%>

<!DOCTYPE html>
<html lang="ko" <%= (loginMember != null && loginMember.isDarkMode()) ? "data-theme=\"dark\"" : "" %>>

<head>
    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>공지사항 관리 - 여행만들기</title>

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
            〉 <span data-i18n="admin.menuNoticesTitle">공지사항 관리</span>
        </p>

        <h1 data-i18n="admin.menuNoticesTitle">공지사항 관리</h1>

        <p class="page-description" data-i18n="adminNotices.pageDesc">
            등록한 공지는 모든 회원의 알림 벨에 표시됩니다.
        </p>

    </section>

    <section class="write-section">

        <form id="noticeForm">

            <div class="write-field">
                <label for="noticeTitle" data-i18n="write.titleLabel">제목</label>
                <input type="text" id="noticeTitle" data-i18n="adminNotices.titlePlaceholder" data-i18n-attr="placeholder" placeholder="공지 제목을 입력해 주세요">
            </div>

            <div class="write-field">
                <label for="noticeContentEditor" data-i18n="support.contentLabel">내용</label>
                <div id="noticeContentEditor" class="quill-editor-container"></div>
                <input type="hidden" id="noticeContent" name="content">
            </div>

            <button type="submit" class="auth-submit" data-i18n="write.submit">등록하기</button>

        </form>

    </section>

    <section class="admin-notice-list-section">

        <% if (noticeList.isEmpty()) { %>
        <p class="ranking-empty" data-i18n="notice.empty">등록된 공지가 없습니다.</p>
        <% } else { %>
        <ul class="admin-notice-list">
            <% for (NoticeDTO notice : noticeList) { %>
            <li class="admin-notice-item" data-notice-id="<%= notice.getNoticeId() %>">

                <div class="admin-notice-item-head">
                    <strong><%= EscapeUtil.html(notice.getTitle()) %></strong>
                    <span><%= notice.getRegDate() %> · <%= EscapeUtil.html(notice.getWriterNick()) %></span>
                </div>

                <div class="detail-body admin-notice-content"><%= notice.getContent() %></div>

                <button type="button" class="admin-notice-delete-button" data-notice-id="<%= notice.getNoticeId() %>" data-i18n="common.delete">삭제</button>

            </li>
            <% } %>
        </ul>
        <% } %>

    </section>

</main>

<%@ include file="/common/footer.jsp" %>
<%@ include file="/common/quill-assets.jspf" %>

<script>
    const noticeQuill = initQuillEditor({
        containerId: "noticeContentEditor",
        hiddenInputId: "noticeContent",
        uploadUrl: "<%= contextPath %>/post/uploadImage",
        loginUrl: "<%= contextPath %>/member/login",
        placeholderKey: "adminNotices.contentPlaceholder",
        placeholderFallback: "공지 내용을 입력해 주세요"
    });

    document.getElementById("noticeForm").addEventListener("submit", function (event) {

        event.preventDefault();

        const title = document.getElementById("noticeTitle").value.trim();
        const bodyIsEmpty = noticeQuill.getText().trim() === "" && noticeQuill.root.querySelectorAll("img").length === 0;

        if (title === "" || bodyIsEmpty) {
            alert(window.t("adminNotices.fillAllAlert", "제목과 내용을 모두 입력해 주세요."));
            return;
        }

        const content = document.getElementById("noticeContent").value;

        const body = new URLSearchParams();
        body.set("title", title);
        body.set("content", content);

        fetch("<%= contextPath %>/admin/notices/create", { method: "POST", body: body })
            .then(function (res) { return res.json(); })
            .then(function (data) {

                if (data.result !== "ok") {
                    alert(window.t("adminNotices.createFailedAlert", "공지 등록에 실패했습니다."));
                    return;
                }

                location.reload();
            });

    });

    document.querySelectorAll(".admin-notice-delete-button").forEach(function (button) {

        button.addEventListener("click", function () {

            if (!confirm(window.t("adminNotices.confirmDelete", "이 공지를 삭제할까요?"))) {
                return;
            }

            const body = new URLSearchParams();
            body.set("noticeId", button.dataset.noticeId);

            fetch("<%= contextPath %>/admin/notices/delete", { method: "POST", body: body })
                .then(function (res) { return res.json(); })
                .then(function (data) {

                    if (data.result !== "ok") {
                        alert(window.t("adminNotices.deleteFailedAlert", "삭제에 실패했습니다."));
                        return;
                    }

                    button.closest(".admin-notice-item").remove();
                });

        });

    });
</script>

</body>
</html>
