<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%@ page import="java.util.List" %>
<%@ page import="model.CommentDTO" %>
<%@ page import="model.MemberDTO" %>
<%@ page import="model.PostDTO" %>
<%@ page import="util.EscapeUtil" %>

<%
    String contextPath = request.getContextPath();

    //이 페이지는 반드시 PostViewCommand(/post/view)를 거쳐서 와야 한다.
    PostDTO post = (PostDTO) request.getAttribute("post");

    if (post == null) {
        response.sendRedirect(contextPath + "/post/list");
        return;
    }

    boolean liked = (Boolean) request.getAttribute("liked");
    boolean scrapped = (Boolean) request.getAttribute("scrapped");
    List<CommentDTO> commentList = (List<CommentDTO>) request.getAttribute("commentList");

    MemberDTO loginMember = (MemberDTO) session.getAttribute("loginMember");
    String loginId = (loginMember == null) ? null : loginMember.getId();

    //남의 글 수정은 admin(레벨 2)만, 삭제는 moderator(레벨 1)부터 가능하다.
    boolean isOwner = loginMember != null && loginMember.getId().equals(post.getWriter());
    boolean canEdit = isOwner || (loginMember != null && loginMember.isAdmin());
    boolean canDelete = isOwner || (loginMember != null && loginMember.isModerator());

    //PostModifyFormCommand/PostDeleteCommand가 "권한 없음" 등을 알리려고 세션에 남겨둔 1회성 메시지
    String flashMsg = (String) session.getAttribute("flashMsg");
    session.removeAttribute("flashMsg");
%>

<!DOCTYPE html>
<html lang="ko" <%= (loginMember != null && loginMember.isDarkMode()) ? "data-theme=\"dark\"" : "" %>>

<head>
    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title><%= EscapeUtil.html(post.getTitle()) %> - 여행만들기</title>

    <%@ include file="/common/css-links.jspf" %>
</head>

<body>

<% String activeNav = "posts"; %>
<%@ include file="/common/header.jsp" %>

<main>

    <section class="page-heading">

        <p class="breadcrumb">
            <a href="<%= contextPath %>/main" data-i18n="nav.home">홈</a>
            〉 <a href="<%= contextPath %>/post/list" data-i18n="posts.title">게시글 목록</a>
            〉 <span data-i18n="detail.breadcrumb">상세</span>
        </p>

    </section>

    <% if (flashMsg != null) { %>
    <p class="field-error"><%= EscapeUtil.html(flashMsg) %></p>
    <% } %>

    <section class="detail-section">

        <div class="detail-header">

            <div class="detail-tags">
                <span class="story-category" data-i18n="country.<%= post.getCountry() %>"><%= EscapeUtil.html(post.getCountryLabel()) %></span>
                <% if (post.getRegion() != null && !post.getRegion().isEmpty()) { %>
                <span class="story-region-tag" data-i18n="region.<%= post.getRegion() %>"><%= EscapeUtil.html(post.getRegionLabel()) %></span>
                <% } %>
                <span class="detail-style-tag" data-i18n="style.<%= post.getStyle() %>"><%= EscapeUtil.html(post.getStyleLabel()) %></span>
            </div>

            <h1><%= EscapeUtil.html(post.getTitle()) %></h1>

            <div class="story-information">
                <span><a href="<%= contextPath %>/member/profile?id=<%= post.getWriter() %>" class="story-writer-link"><%= EscapeUtil.html(post.getWriterNick()) %></a></span>
                <span><%= post.getRegDate() %><% if (post.getModDate() != null) { %> (<span data-i18n="detail.edited">수정</span> <%= post.getModDate() %>)<% } %></span>
                <span><span data-i18n="common.viewCount">조회</span> <%= post.getViewCnt() %></span>
                <span><span data-i18n="detail.comments">댓글</span> <span id="commentCountInline"><%= commentList.size() %></span></span>
            </div>

        </div>

        <%-- 본문 안에 쓴 이미지가 그대로 보이므로(에디터로 작성), 따로 대표 이미지를 안 보여준다.
             post.getContent()는 PostWriteCommand/PostModifyCommand가 저장 전에 HtmlSanitizer로
             걸러낸 HTML이라 그대로 출력해도 안전하다 (EscapeUtil.html을 쓰면 서식이 다 깨진다). --%>
        <div class="detail-body"><%= post.getContent() %></div>

        <div class="detail-reactions">

            <button type="button"
                    id="likeButton"
                    class="reaction-button <%= liked ? "active" : "" %>"
                    data-bno="<%= post.getBno() %>">
                <span class="reaction-icon" id="likeIcon"><%= liked ? "♥" : "♡" %></span>
                <span data-i18n="common.likeCount">좋아요</span> <span id="likeCount"><%= post.getLikeCnt() %></span>
            </button>

            <button type="button"
                    id="scrapButton"
                    class="reaction-button <%= scrapped ? "active" : "" %>"
                    data-bno="<%= post.getBno() %>">
                <span class="reaction-icon" id="scrapIcon"><%= scrapped ? "★" : "☆" %></span>
                <span id="scrapLabel" data-i18n="<%= scrapped ? "detail.scraped" : "detail.scrap" %>"><%= scrapped ? "스크랩됨" : "스크랩" %></span>
            </button>

        </div>

        <% if (canEdit || canDelete) { %>
        <div class="detail-actions">

            <% if (canEdit) { %>
            <a href="<%= contextPath %>/post/modify?bno=<%= post.getBno() %>"
               class="detail-edit-button"
               data-i18n="common.edit">
                수정
            </a>
            <% } %>

            <% if (canDelete) { %>
            <form method="post"
                  action="<%= contextPath %>/post/delete"
                  onsubmit="return confirm(window.t('detail.confirmDeletePost', '이 게시글을 삭제하시겠습니까?'));">

                <input type="hidden" name="bno" value="<%= post.getBno() %>">

                <button type="submit" class="detail-delete-button" data-i18n="common.delete">
                    삭제
                </button>

            </form>
            <% } %>

        </div>
        <% } %>

        <section class="comment-section">

            <h2><span data-i18n="detail.comments">댓글</span> <span id="commentCount"><%= commentList.size() %></span></h2>

            <% if (loginMember != null) { %>
            <form id="commentForm" class="comment-form">

                <textarea id="commentInput"
                          rows="3"
                          maxlength="500"
                          data-i18n="detail.commentPlaceholder"
                          data-i18n-attr="placeholder"
                          placeholder="댓글을 남겨보세요 (최대 500자)"></textarea>

                <button type="submit" class="comment-submit" data-i18n="detail.commentSubmit">
                    댓글 등록
                </button>

            </form>
            <% } else { %>
            <p class="comment-empty">
                <a href="<%= contextPath %>/member/login" data-i18n="nav.login">로그인</a> <span data-i18n="detail.loginToComment">후 댓글을 작성할 수 있습니다.</span>
            </p>
            <% } %>

            <ul class="comment-list" id="commentList">

                <% for (CommentDTO comment : commentList) {

                    boolean canDeleteComment = loginId != null
                        && (loginId.equals(comment.getWriter())
                            || loginId.equals(post.getWriter())
                            || loginMember.isModerator());
                %>
                <li class="comment-item" data-cno="<%= comment.getCno() %>">

                    <div class="comment-head">
                        <strong><a href="<%= contextPath %>/member/profile?id=<%= comment.getWriter() %>" class="story-writer-link"><%= EscapeUtil.html(comment.getWriterNick()) %></a></strong>
                        <% if (comment.getWriter().equals(post.getWriter())) { %>
                        <span class="my-post-badge" data-i18n="detail.postAuthor">작성자</span>
                        <% } %>
                        <span class="comment-time"><%= comment.getRegDate() %></span>
                        <% if (canDeleteComment) { %>
                        <button type="button" class="comment-delete" data-cno="<%= comment.getCno() %>" data-i18n="common.delete">삭제</button>
                        <% } %>
                    </div>

                    <p class="comment-body"><%= EscapeUtil.html(comment.getContent()) %></p>

                </li>
                <% } %>

            </ul>

            <p class="comment-empty" id="commentEmpty" data-i18n="detail.noComments" <%= commentList.isEmpty() ? "" : "hidden" %>>
                아직 댓글이 없습니다. 첫 댓글을 남겨보세요.
            </p>

        </section>

        <div class="detail-back">
            <a href="<%= contextPath %>/post/list">
                〈 <span data-i18n="detail.backToList">목록으로</span>
            </a>
        </div>

    </section>

</main>

<%@ include file="/common/footer.jsp" %>

<script>
    const contextPath = "<%= contextPath %>";
    const isLoggedIn = <%= loginMember != null %>;

    /*
     * 좋아요 / 스크랩은 페이지를 새로고침하지 않고 서버에 POST로 알린 뒤
     * 응답(JSON)으로 화면만 바꾼다.
     */

    function requireLogin() {

        if (isLoggedIn) {
            return true;
        }

        if (confirm(window.t("detail.confirmLoginRedirect", "로그인 후 이용할 수 있습니다. 로그인 페이지로 이동하시겠습니까?"))) {
            location.href = contextPath + "/member/login";
        }

        return false;
    }

    function postForm(url, params) {

        const body = new URLSearchParams(params);

        return fetch(url, {
            method: "POST",
            headers: { "Content-Type": "application/x-www-form-urlencoded" },
            body: body.toString()
        }).then(function (res) {
            return res.json();
        });
    }

    const likeButton = document.getElementById("likeButton");

    likeButton.addEventListener("click", function () {

        if (!requireLogin()) {
            return;
        }

        likeButton.disabled = true;

        postForm(contextPath + "/post/like", { bno: likeButton.dataset.bno })
            .then(function (data) {

                if (data.result === "login") {
                    location.href = contextPath + "/member/login";
                    return;
                }

                if (data.result === "suspended") {
                    alert(window.t("detail.suspendedLike", "활동이 정지된 계정은 좋아요를 누를 수 없습니다."));
                    return;
                }

                if (data.result !== "ok") {
                    alert(window.t("detail.likeFailed", "좋아요 처리에 실패했습니다."));
                    return;
                }

                likeButton.classList.toggle("active", data.liked);
                document.getElementById("likeIcon").textContent = data.liked ? "♥" : "♡";
                document.getElementById("likeCount").textContent = data.likeCnt;

            })
            .finally(function () {
                likeButton.disabled = false;
            });

    });

    const scrapButton = document.getElementById("scrapButton");

    scrapButton.addEventListener("click", function () {

        if (!requireLogin()) {
            return;
        }

        scrapButton.disabled = true;

        postForm(contextPath + "/post/scrap", { bno: scrapButton.dataset.bno })
            .then(function (data) {

                if (data.result === "login") {
                    location.href = contextPath + "/member/login";
                    return;
                }

                if (data.result !== "ok") {
                    alert(window.t("detail.scrapFailed", "스크랩 처리에 실패했습니다."));
                    return;
                }

                scrapButton.classList.toggle("active", data.scrapped);
                document.getElementById("scrapIcon").textContent = data.scrapped ? "★" : "☆";
                document.getElementById("scrapLabel").textContent = data.scrapped
                    ? window.t("detail.scraped", "스크랩됨")
                    : window.t("detail.scrap", "스크랩");

            })
            .finally(function () {
                scrapButton.disabled = false;
            });

    });


    /*
     * 댓글 작성/삭제도 같은 방식(Ajax)으로 처리한다.
     * 새 댓글은 서버가 돌려준 값으로 <li>를 그대로 만들어 붙인다.
     */

    const commentForm = document.getElementById("commentForm");
    const commentList = document.getElementById("commentList");
    const bno = <%= post.getBno() %>;
    const postWriter = "<%= EscapeUtil.json(post.getWriter()) %>";

    function escapeHtml(text) {
        const div = document.createElement("div");
        div.textContent = text;
        return div.innerHTML;
    }

    function updateCommentCount(count) {
        document.getElementById("commentCount").textContent = count;
        document.getElementById("commentCountInline").textContent = count;
        document.getElementById("commentEmpty").hidden = count !== 0;
    }

    if (commentForm) {

        commentForm.addEventListener("submit", function (event) {

            event.preventDefault();

            const input = document.getElementById("commentInput");
            const content = input.value.trim();

            if (content === "") {
                alert(window.t("detail.commentEmptyAlert", "댓글 내용을 입력해 주세요."));
                return;
            }

            const submitButton = commentForm.querySelector("button[type='submit']");
            submitButton.disabled = true;

            postForm(contextPath + "/comment/write", { bno: bno, content: content })
                .then(function (data) {

                    if (data.result === "login") {
                        location.href = contextPath + "/member/login";
                        return;
                    }

                    if (data.result === "suspended") {
                        alert(window.t("detail.suspendedComment", "활동이 정지된 계정은 댓글을 남길 수 없습니다."));
                        return;
                    }

                    if (data.result !== "ok") {
                        alert(window.t("detail.commentFailed", "댓글 등록에 실패했습니다."));
                        return;
                    }

                    const canDelete = true;   // 방금 내가 쓴 댓글이므로 항상 삭제 가능

                    const li = document.createElement("li");
                    li.className = "comment-item";
                    li.dataset.cno = data.cno;

                    li.innerHTML =
                        '<div class="comment-head">'
                        + '<strong>' + escapeHtml(data.writerNick) + '</strong>'
                        + (data.writer === postWriter ? '<span class="my-post-badge">' + window.t("detail.postAuthor", "작성자") + '</span>' : '')
                        + '<span class="comment-time">' + window.t("detail.justNow", "방금 전") + '</span>'
                        + (canDelete ? '<button type="button" class="comment-delete" data-cno="' + data.cno + '">' + window.t("common.delete", "삭제") + '</button>' : '')
                        + '</div>'
                        + '<p class="comment-body">' + escapeHtml(data.content) + '</p>';

                    commentList.appendChild(li);

                    input.value = "";

                    updateCommentCount(data.commentCnt);

                })
                .finally(function () {
                    submitButton.disabled = false;
                });

        });
    }

    commentList.addEventListener("click", function (event) {

        const deleteButton = event.target.closest(".comment-delete");

        if (!deleteButton) {
            return;
        }

        if (!confirm(window.t("detail.confirmDeleteComment", "이 댓글을 삭제하시겠습니까?"))) {
            return;
        }

        deleteButton.disabled = true;

        postForm(contextPath + "/comment/delete", { cno: deleteButton.dataset.cno })
            .then(function (data) {

                if (data.result === "login") {
                    location.href = contextPath + "/member/login";
                    return;
                }

                if (data.result === "forbidden") {
                    alert(window.t("detail.deleteForbidden", "삭제 권한이 없습니다."));
                    deleteButton.disabled = false;
                    return;
                }

                if (data.result !== "ok") {
                    alert(window.t("detail.commentDeleteFailed", "댓글 삭제에 실패했습니다."));
                    deleteButton.disabled = false;
                    return;
                }

                deleteButton.closest(".comment-item").remove();

                updateCommentCount(data.commentCnt);

            });

    });
</script>

</body>
</html>
