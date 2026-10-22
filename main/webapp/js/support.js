/*
 * FAQ 아코디언 - 질문을 누르면 답변이 펼쳐지고, 다시 누르면 접힌다.
 */

document.querySelectorAll(".faq-question").forEach(function (button) {

    button.addEventListener("click", function () {

        const answer = button.parentElement.querySelector(".faq-answer");
        const icon = button.querySelector(".faq-toggle-icon");

        answer.hidden = !answer.hidden;
        icon.textContent = answer.hidden ? "+" : "−";

    });

});

/*
 * #faq / #contact로 바로 들어온 경우, 헤더 높이만큼 가려지지 않도록 살짝 내려서 스크롤한다.
 */

if (location.hash === "#faq" || location.hash === "#contact") {

    const target = document.getElementById(location.hash.slice(1));

    if (target) {
        window.scrollTo({ top: target.offsetTop - 90 });
    }

}
