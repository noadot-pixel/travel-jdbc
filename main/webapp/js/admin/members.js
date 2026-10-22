function toggleSuspend(row, suspend) {

    const id = row.dataset.memberId;

    const body = new URLSearchParams();
    body.set("id", id);
    body.set("suspend", suspend ? "Y" : "N");

    fetch(window.contextPath + "/admin/members/suspend", { method: "POST", body: body })
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

        fetch(window.contextPath + "/admin/members/setLevel", { method: "POST", body: body })
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
