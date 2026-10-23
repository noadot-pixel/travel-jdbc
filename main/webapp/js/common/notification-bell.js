/*
 * 알림 벨 - 클릭하면 공지 최신 5개 + 내 활동 알림(댓글/좋아요) 최신 10개를 불러와 보여주고,
 * 서버에서 그 자리에 전부 읽음 처리한다(다음에 열 때 배지가 0부터 다시 쌓임).
 */

(function () {

    const button = document.getElementById("notifBellButton");
    const dropdown = document.getElementById("notifDropdown");
    const badge = button.querySelector(".notif-badge");

    let loaded = false;
    let lastData = null;   // 마지막으로 받아온 데이터 - 언어를 바꾸면 다시 그릴 때 쓴다(재요청 안 함)

    function escapeHtml(str) {
        const div = document.createElement("div");
        div.textContent = str;
        return div.innerHTML;
    }

    //서버는 "누가/뭘 했는지/어느 글인지"만 보내고, 실제 문장은 여기서 언어에 맞게 조립한다
    //(서버에서 한국어로 완성된 문장을 보내버리면 언어를 바꿔도 그대로 남기 때문).
    function buildAlertMessage(a) {

        const title = a.type === "INQUIRY_COMMENT" ? a.inquiryTitle : a.postTitle;

        let suffixKey, suffixFallback;
        if (a.type === "LIKE") {
            suffixKey = "notif.likeSuffix";
            suffixFallback = "님이 내 글을 좋아합니다";
        } else if (a.type === "INQUIRY_COMMENT") {
            suffixKey = "notif.inquiryCommentSuffix";
            suffixFallback = "님이 문의에 댓글을 남겼습니다";
        } else {
            suffixKey = "notif.commentSuffix";
            suffixFallback = "님이 내 글에 댓글을 남겼습니다";
        }

        return a.actorNick + window.t(suffixKey, suffixFallback) + " - " + title;
    }

    function render(data) {

        lastData = data;

        const parts = [];

        if (data.notices.length > 0) {
            parts.push('<p class="notif-section-title">' + escapeHtml(window.t("notif.noticesSectionTitle", "공지")) + '</p>');
            data.notices.forEach(function (n) {
                parts.push(
                    '<a href="' + window.contextPath + '/notice/view?noticeId=' + n.noticeId + '" ' +
                        'class="notif-item notif-notice-item" title="' + escapeHtml(n.content) + '">' +
                        '<strong>' + escapeHtml(n.title) + '</strong>' +
                        '<span>' + escapeHtml(n.regDate) + '</span>' +
                    '</a>'
                );
            });
        }

        if (data.alerts.length > 0) {
            parts.push('<p class="notif-section-title">' + escapeHtml(window.t("notif.myAlertsSectionTitle", "내 알림")) + '</p>');
            data.alerts.forEach(function (a) {
                const href = a.targetType === "INQUIRY"
                    ? window.contextPath + "/support/view?inquiryId=" + a.inquiryId
                    : window.contextPath + "/post/view?bno=" + a.bno;
                parts.push(
                    '<a href="' + href + '" class="notif-item notif-alert-item' +
                        (a.read ? '' : ' notif-unread') + '">' +
                        '<span>' + escapeHtml(buildAlertMessage(a)) + '</span>' +
                        '<span>' + escapeHtml(a.regDate) + '</span>' +
                    '</a>'
                );
            });
        }

        if (parts.length === 0) {
            parts.push('<p class="notif-empty">' + escapeHtml(window.t("notif.empty", "새 소식이 없습니다.")) + '</p>');
        }

        dropdown.innerHTML = parts.join("");
    }

    button.addEventListener("click", function (event) {

        event.stopPropagation();

        dropdown.hidden = !dropdown.hidden;

        if (dropdown.hidden || loaded) {
            return;
        }

        fetch(window.contextPath + "/notification/list")
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

    //드롭다운을 열어둔 채로 언어를 바꾸면, 이미 받아온 데이터로 문장만 다시 조립해서 보여준다
    //(서버에 다시 요청하지 않음 - 어차피 한 번 열면 서버가 전부 읽음 처리해버려서 다시 불러도 같은 데이터).
    $(document).on("i18n:applied", function () {
        if (lastData) {
            render(lastData);
        }
    });

})();
