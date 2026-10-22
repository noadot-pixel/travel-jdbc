/*
 * 국가를 "기타"로 선택했을 때만 자유 입력란을 보여준다.
 */

const countrySelect = document.getElementById("profileCountry");
const countryOtherField = document.getElementById("profileCountryOtherField");

countrySelect.addEventListener("change", function () {
    countryOtherField.hidden = countrySelect.value !== "ETC";
});


/*
 * 프로필 이미지를 고르면 바로 미리보기로 보여준다. 실제 업로드는 저장할 때 한 번만 일어난다.
 */

const profilePhotoInput = document.getElementById("profilePhoto");
const profilePhotoPreview = document.getElementById("profilePhotoPreview");

profilePhotoInput.addEventListener("change", function () {

    const file = profilePhotoInput.files[0];

    if (!file) {
        return;
    }

    const reader = new FileReader();

    reader.onload = function (event) {
        profilePhotoPreview.src = event.target.result;
    };

    reader.readAsDataURL(file);

});


/*
 * 닉네임 형식은 서버(ProfileEditCommand)에서도 똑같이 검사하지만, 제출 전에 미리 알려준다.
 */

document.getElementById("profileForm").addEventListener("submit", function (event) {

    const nickname = document.getElementById("profileNickname").value.trim();

    if (!/^[\p{L}\p{N}]{2,12}$/u.test(nickname)) {
        event.preventDefault();
        alert(window.t("auth.nicknameInvalidAlert", "닉네임은 특수문자·공백 없이 2~12자로 입력해 주세요."));
    }

});


/*
 * 닉네임 중복확인 - 원래 닉네임 그대로면(안 바꿨으면) 굳이 또 확인하라고 막지 않는다.
 * 바꿨을 때만 저장 전에 중복확인을 거치게 한다.
 */

(function () {

    const originalNickname = window.originalNickname;
    const nicknameInput = document.getElementById("profileNickname");
    const nicknameCheckButton = document.getElementById("nicknameCheckButton");
    const nicknameCheckResult = document.getElementById("nicknameCheckResult");
    let nicknameChecked = false;

    nicknameCheckButton.addEventListener("click", function () {

        const nickname = nicknameInput.value.trim();

        if (!/^[\p{L}\p{N}]{2,12}$/u.test(nickname)) {
            nicknameChecked = false;
            nicknameCheckResult.textContent = window.t("auth.nicknameInvalidAlert", "닉네임은 특수문자·공백 없이 2~12자로 입력해 주세요.");
            nicknameCheckResult.className = "write-field-note field-hint-error";
            return;
        }

        fetch(window.contextPath + "/member/nicknameCheck?nickname=" + encodeURIComponent(nickname))
            .then(function (res) { return res.json(); })
            .then(function (data) {

                if (data.result === "available") {
                    nicknameChecked = true;
                    nicknameCheckResult.textContent = window.t("auth.nicknameCheckAvailable", "사용 가능한 닉네임입니다.");
                    nicknameCheckResult.className = "write-field-note field-hint-ok";
                } else if (data.result === "duplicate") {
                    nicknameChecked = false;
                    nicknameCheckResult.textContent = window.t("auth.nicknameCheckDuplicate", "이미 사용 중인 닉네임입니다.");
                    nicknameCheckResult.className = "write-field-note field-hint-error";
                } else {
                    nicknameChecked = false;
                    nicknameCheckResult.textContent = window.t("auth.nicknameInvalidAlert", "닉네임은 특수문자·공백 없이 2~12자로 입력해 주세요.");
                    nicknameCheckResult.className = "write-field-note field-hint-error";
                }

            });

    });

    nicknameInput.addEventListener("input", function () {
        nicknameChecked = false;
        nicknameCheckResult.textContent = "";
    });

    document.getElementById("profileForm").addEventListener("submit", function (event) {

        const nickname = nicknameInput.value.trim();

        if (nickname !== originalNickname && !nicknameChecked) {
            event.preventDefault();
            alert(window.t("auth.nicknameCheckRequiredAlert", "닉네임 중복확인을 먼저 해 주세요."));
        }

    });

})();
