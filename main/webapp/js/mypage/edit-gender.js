/*
 * 성별 버튼 선택과, 제출 전 필수 입력 검사(서버에서도 똑같이 검사함).
 * 이 스크립트는 gender가 아직 null인 회원에게만 로드된다 - mypage/edit.jsp가
 * 이 스크립트 태그 자체를 조건부로(loginMember.getGender() == null일 때만)
 * 출력한다. 이 화면을 저장하려면 성별/동의를 전부 채워야 한다.
 */

const genderGroup = document.getElementById("profileGenderGroup");
const genderInput = document.getElementById("genderInput");

genderGroup.querySelectorAll(".filter-button").forEach(function (button) {

    button.addEventListener("click", function () {

        genderGroup.querySelectorAll(".filter-button").forEach(function (other) {
            other.classList.remove("active");
        });

        button.classList.add("active");
        genderInput.value = button.dataset.gender;

    });

});

document.getElementById("profileForm").addEventListener("submit", function (event) {

    const privacyAgree = document.getElementById("privacyAgree").checked;

    if (genderInput.value === "") {
        event.preventDefault();
        alert(window.t("editProfile.genderRequiredAlert", "성별을 선택해 주세요."));
        return;
    }

    if (!privacyAgree) {
        event.preventDefault();
        alert(window.t("editProfile.privacyRequiredAlert", "개인정보 수집·이용에 동의해야 저장할 수 있습니다."));
    }

});
