/*
 * 알림 벨 - 클릭하면 공지 최신 5개 + 내 활동 알림(댓글/좋아요) 최신 10개를 불러와 보여주고,
 * 서버에서 그 자리에 전부 읽음 처리한다(다음에 열 때 배지가 0부터 다시 쌓임).
 */

(function () {

    const button = document.getElementById("notifBellButton");
    const dropdown = document.getElementById("notifDropdown");
    const badge = button.querySelector(".notif-badge");

    let loaded = false;

    function escapeHtml(str) {
        const div = document.createElement("div");
        div.textContent = str;
        return div.innerHTML;
    }

    function render(data) {

        const parts = [];

        if (data.notices.length > 0) {
            parts.push('<p class="notif-section-title">공지</p>');
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
            parts.push('<p class="notif-section-title">내 알림</p>');
            data.alerts.forEach(function (a) {
                const href = a.targetType === "INQUIRY"
                    ? window.contextPath + "/support/view?inquiryId=" + a.inquiryId
                    : window.contextPath + "/post/view?bno=" + a.bno;
                parts.push(
                    '<a href="' + href + '" class="notif-item notif-alert-item' +
                        (a.read ? '' : ' notif-unread') + '">' +
                        '<span>' + escapeHtml(a.message) + '</span>' +
                        '<span>' + escapeHtml(a.regDate) + '</span>' +
                    '</a>'
                );
            });
        }

        if (parts.length === 0) {
            parts.push('<p class="notif-empty">새 소식이 없습니다.</p>');
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

})();
