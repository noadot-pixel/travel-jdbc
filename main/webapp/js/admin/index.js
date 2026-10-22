document.getElementById("seedButton")
    .addEventListener("click", function () {

        fetch(window.contextPath + "/admin/seed", { method: "POST" })
            .then(function (res) { return res.json(); })
            .then(function (data) {

                if (data.added === 0) {
                    alert(window.t("admin.seedAlreadyExists", "이미 게시글이 있어서 시드를 추가하지 않았습니다."));
                } else {
                    alert(data.added + window.t("admin.seedAddedSuffix", "개의 예시 게시글을 추가했습니다."));
                }

            });

    });
