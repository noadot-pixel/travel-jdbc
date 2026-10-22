const isLoggedIn = window.detailData.isLoggedIn;

/*
 * 좋아요 / 스크랩은 페이지를 새로고침하지 않고 서버에 POST로 알린 뒤
 * 응답(JSON)으로 화면만 바꾼다.
 */

function requireLogin() {

    if (isLoggedIn) {
        return true;
    }

    if (confirm(window.t("detail.confirmLoginRedirect", "로그인 후 이용할 수 있습니다. 로그인 페이지로 이동하시겠습니까?"))) {
        location.href = window.contextPath + "/member/login";
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

    postForm(window.contextPath + "/post/like", { bno: likeButton.dataset.bno })
        .then(function (data) {

            if (data.result === "login") {
                location.href = window.contextPath + "/member/login";
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

    postForm(window.contextPath + "/post/scrap", { bno: scrapButton.dataset.bno })
        .then(function (data) {

            if (data.result === "login") {
                location.href = window.contextPath + "/member/login";
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
const bno = window.detailData.bno;
const postWriter = window.detailData.postWriter;

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

        postForm(window.contextPath + "/comment/write", { bno: bno, content: content })
            .then(function (data) {

                if (data.result === "login") {
                    location.href = window.contextPath + "/member/login";
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

    postForm(window.contextPath + "/comment/delete", { cno: deleteButton.dataset.cno })
        .then(function (data) {

            if (data.result === "login") {
                location.href = window.contextPath + "/member/login";
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
