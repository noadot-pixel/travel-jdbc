document.getElementById("faqForm").addEventListener("submit", function (event) {

    event.preventDefault();

    const question = document.getElementById("faqQuestion").value.trim();
    const answer = document.getElementById("faqAnswer").value.trim();

    if (question === "" || answer === "") {
        alert(window.t("adminFaqs.fillAllAlert", "질문과 답변을 모두 입력해 주세요."));
        return;
    }

    const body = new URLSearchParams();
    body.set("question", question);
    body.set("answer", answer);

    fetch(window.contextPath + "/admin/faqs/create", { method: "POST", body: body })
        .then(function (res) { return res.json(); })
        .then(function (data) {

            if (data.result !== "ok") {
                alert(window.t("adminFaqs.createFailedAlert", "등록에 실패했습니다."));
                return;
            }

            location.reload();
        });

});

document.querySelectorAll(".admin-faq-item").forEach(function (item) {

    const faqId = item.dataset.faqId;
    const viewBox = item.querySelector(".admin-faq-view");
    const editBox = item.querySelector(".admin-faq-edit-form");

    item.querySelector(".admin-faq-edit-button").addEventListener("click", function () {
        viewBox.hidden = true;
        editBox.hidden = false;
    });

    item.querySelector(".admin-faq-cancel-button").addEventListener("click", function () {
        editBox.hidden = true;
        viewBox.hidden = false;
    });

    item.querySelector(".admin-faq-save-button").addEventListener("click", function () {

        const question = item.querySelector(".admin-faq-edit-question").value.trim();
        const answer = item.querySelector(".admin-faq-edit-answer").value.trim();

        if (question === "" || answer === "") {
            alert(window.t("adminFaqs.fillAllAlert", "질문과 답변을 모두 입력해 주세요."));
            return;
        }

        const body = new URLSearchParams();
        body.set("faqId", faqId);
        body.set("question", question);
        body.set("answer", answer);

        fetch(window.contextPath + "/admin/faqs/update", { method: "POST", body: body })
            .then(function (res) { return res.json(); })
            .then(function (data) {

                if (data.result !== "ok") {
                    alert(window.t("adminFaqs.updateFailedAlert", "수정에 실패했습니다."));
                    return;
                }

                location.reload();
            });

    });

    item.querySelector(".admin-faq-delete-button").addEventListener("click", function () {

        if (!confirm(window.t("adminFaqs.confirmDelete", "이 FAQ를 삭제할까요?"))) {
            return;
        }

        const body = new URLSearchParams();
        body.set("faqId", faqId);

        fetch(window.contextPath + "/admin/faqs/delete", { method: "POST", body: body })
            .then(function (res) { return res.json(); })
            .then(function (data) {

                if (data.result !== "ok") {
                    alert(window.t("adminNotices.deleteFailedAlert", "삭제에 실패했습니다."));
                    return;
                }

                item.remove();
            });

    });

});
