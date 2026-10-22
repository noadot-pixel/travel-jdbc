/*
 * 활동 종류 라디오를 바꾸면 검색어는 비우고(종류가 바뀌면 이전 검색어가 안 맞을 수
 * 있어서) 그 종류의 1페이지로 새로 이동한다.
 */

document.querySelectorAll('#activityTypeWrap input[name="activityType"]').forEach(function (radio) {

    radio.addEventListener("change", function () {
        location.href = window.contextPath + "/member/mypage?type=" + radio.value;
    });

});

/*
 * 스크랩 해제 버튼은 /post/scrap(Ajax 전용 JSON 엔드포인트)으로 그냥 폼 전송하면
 * 화면에 JSON이 그대로 떠버리므로, 폼 제출 대신 fetch로 보내고 성공하면 새로고침한다.
 */

document.querySelectorAll(".scrap-remove-form").forEach(function (form) {

    form.addEventListener("submit", function (event) {

        event.preventDefault();

        const bno = form.querySelector('input[name="bno"]').value;

        fetch(form.action, {
            method: "POST",
            headers: { "Content-Type": "application/x-www-form-urlencoded" },
            body: "bno=" + encodeURIComponent(bno)
        })
        .then(function () {
            location.reload();
        });

    });

});

/*
 * 댓글 삭제도 scrap-remove-form과 같은 이유로 fetch로 보낸다 - CommentDeleteCommand는
 * Ajax 전용 JSON 엔드포인트라 폼을 그대로 제출하면 화면에 JSON이 떠버린다.
 */

document.querySelectorAll(".comment-remove-form").forEach(function (form) {

    form.addEventListener("submit", function (event) {

        event.preventDefault();

        const cno = form.querySelector('input[name="cno"]').value;

        fetch(form.action, {
            method: "POST",
            headers: { "Content-Type": "application/x-www-form-urlencoded" },
            body: "cno=" + encodeURIComponent(cno)
        })
        .then(function (res) { return res.json(); })
        .then(function (data) {

            if (data.result === "login") {
                location.href = window.contextPath + "/member/login";
                return;
            }

            if (data.result !== "ok") {
                alert(window.t("detail.commentDeleteFailed", "댓글 삭제에 실패했습니다."));
                return;
            }

            location.reload();

        });

    });

});
