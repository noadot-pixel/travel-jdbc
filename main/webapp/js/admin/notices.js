const noticeQuill = initQuillEditor({
    containerId: "noticeContentEditor",
    hiddenInputId: "noticeContent",
    uploadUrl: window.contextPath + "/post/uploadImage",
    loginUrl: window.contextPath + "/member/login",
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

    fetch(window.contextPath + "/admin/notices/create", { method: "POST", body: body })
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

        fetch(window.contextPath + "/admin/notices/delete", { method: "POST", body: body })
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
