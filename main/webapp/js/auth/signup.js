/*
 * 성별 버튼 하나만 선택되도록 처리하고, 고른 값을 hidden input에 채워서 서버로 보낸다
 * (write.jsp/edit.jsp에서 쓰는 것과 같은 방식).
 */

function bindFilterGroup(groupId, hiddenInputId, datasetKey) {

    const group = document.getElementById(groupId);
    const hiddenInput = document.getElementById(hiddenInputId);
    const buttons = group.querySelectorAll(".filter-button");

    buttons.forEach(function (button) {

        button.addEventListener("click", function () {

            buttons.forEach(function (other) {
                other.classList.remove("active");
            });

            button.classList.add("active");

            hiddenInput.value = button.dataset[datasetKey];

        });

    });

}

bindFilterGroup("signupGenderGroup", "genderInput", "gender");

//비밀번호 보기 버튼 - bindPasswordReveal 자체는 js/common/password-reveal.js(로그인 폼과 공용).
bindPasswordReveal("signupPasswordToggle", "signupPassword");
bindPasswordReveal("signupPasswordConfirmToggle", "signupPasswordConfirm");

/*
 * 아이디(이메일) 중복확인 - 버튼을 누르면 서버에 바로 물어본다(IdCheckCommand).
 * 이메일을 다시 고치면 "확인됨" 상태를 지워서, 바뀐 값으로 다시 확인하게 만든다.
 */

const emailInput = document.getElementById("signupEmail");
const idCheckButton = document.getElementById("idCheckButton");
const idCheckResult = document.getElementById("idCheckResult");
let emailChecked = false;

idCheckButton.addEventListener("click", function () {

    const email = emailInput.value.trim();

    if (email === "") {
        idCheckResult.textContent = window.t("auth.idCheckEmpty", "이메일을 먼저 입력해 주세요.");
        idCheckResult.className = "field-hint field-hint-error";
        return;
    }

    fetch(window.contextPath + "/member/idCheck?id=" + encodeURIComponent(email))
        .then(function (res) { return res.json(); })
        .then(function (data) {

            if (data.result === "available") {
                emailChecked = true;
                idCheckResult.textContent = window.t("auth.idCheckAvailable", "사용 가능한 이메일입니다.");
                idCheckResult.className = "field-hint field-hint-ok";
            } else if (data.result === "duplicate") {
                emailChecked = false;
                idCheckResult.textContent = window.t("auth.idCheckDuplicate", "이미 사용 중인 이메일입니다.");
                idCheckResult.className = "field-hint field-hint-error";
            } else {
                emailChecked = false;
                idCheckResult.textContent = window.t("auth.idCheckInvalid", "이메일 형식이 올바르지 않습니다.");
                idCheckResult.className = "field-hint field-hint-error";
            }

        });

});

emailInput.addEventListener("input", function () {
    emailChecked = false;
    idCheckResult.textContent = "";
});

/*
 * 닉네임 중복확인 - 이메일과 같은 방식(NicknameCheckCommand). 형식이 안 맞으면
 * 서버에 묻지 않고 바로 안내한다(어차피 가입도 안 될 형식이라 서버까지 갈 필요 없음).
 */

const nicknameInput = document.getElementById("signupNickname");
const nicknameCheckButton = document.getElementById("nicknameCheckButton");
const nicknameCheckResult = document.getElementById("nicknameCheckResult");
let nicknameChecked = false;

nicknameCheckButton.addEventListener("click", function () {

    const nickname = nicknameInput.value.trim();

    if (!/^[\p{L}\p{N}]{2,12}$/u.test(nickname)) {
        nicknameChecked = false;
        nicknameCheckResult.textContent = window.t("auth.nicknameInvalidAlert", "닉네임은 특수문자·공백 없이 2~12자로 입력해 주세요.");
        nicknameCheckResult.className = "field-hint field-hint-error";
        return;
    }

    fetch(window.contextPath + "/member/nicknameCheck?nickname=" + encodeURIComponent(nickname))
        .then(function (res) { return res.json(); })
        .then(function (data) {

            if (data.result === "available") {
                nicknameChecked = true;
                nicknameCheckResult.textContent = window.t("auth.nicknameCheckAvailable", "사용 가능한 닉네임입니다.");
                nicknameCheckResult.className = "field-hint field-hint-ok";
            } else if (data.result === "duplicate") {
                nicknameChecked = false;
                nicknameCheckResult.textContent = window.t("auth.nicknameCheckDuplicate", "이미 사용 중인 닉네임입니다.");
                nicknameCheckResult.className = "field-hint field-hint-error";
            } else {
                nicknameChecked = false;
                nicknameCheckResult.textContent = window.t("auth.nicknameInvalidAlert", "닉네임은 특수문자·공백 없이 2~12자로 입력해 주세요.");
                nicknameCheckResult.className = "field-hint field-hint-error";
            }

        });

});

nicknameInput.addEventListener("input", function () {
    nicknameChecked = false;
    nicknameCheckResult.textContent = "";
});

/*
 * 비밀번호 확인 - 입력하는 동안 바로 일치 여부를 보여준다(제출 전 미리 알려주기).
 */

const passwordInput = document.getElementById("signupPassword");
const passwordConfirmInput = document.getElementById("signupPasswordConfirm");
const passwordMatchResult = document.getElementById("passwordMatchResult");

function checkPasswordMatch() {

    if (passwordConfirmInput.value === "") {
        passwordMatchResult.textContent = "";
        return;
    }

    if (passwordInput.value === passwordConfirmInput.value) {
        passwordMatchResult.textContent = window.t("auth.passwordMatchOk", "비밀번호가 일치합니다.");
        passwordMatchResult.className = "field-hint field-hint-ok";
    } else {
        passwordMatchResult.textContent = window.t("auth.passwordMatchFail", "비밀번호가 일치하지 않습니다.");
        passwordMatchResult.className = "field-hint field-hint-error";
    }
}

passwordInput.addEventListener("input", checkPasswordMatch);
passwordConfirmInput.addEventListener("input", checkPasswordMatch);

/*
 * 서버에서도 똑같이 검사하지만(JoinCommand), 사용자 편의를 위해 제출 전에 미리 알려준다.
 */

document.getElementById("signupForm").addEventListener("submit", function (event) {

    const nickname = document.getElementById("signupNickname").value.trim();
    const email = document.getElementById("signupEmail").value.trim();
    const password = document.getElementById("signupPassword").value;
    const passwordConfirm = document.getElementById("signupPasswordConfirm").value;
    const gender = document.getElementById("genderInput").value;
    const privacyAgree = document.getElementById("privacyAgree").checked;

    if (nickname === "" || email === "" || password === "" || passwordConfirm === ""
        || gender === "") {
        event.preventDefault();
        alert(window.t("auth.fillAllAlert", "모든 항목을 입력해 주세요."));
        return;
    }

    if (!/^[\p{L}\p{N}]{2,12}$/u.test(nickname)) {
        event.preventDefault();
        alert(window.t("auth.nicknameInvalidAlert", "닉네임은 특수문자·공백 없이 2~12자로 입력해 주세요."));
        return;
    }

    if (!emailChecked) {
        event.preventDefault();
        alert(window.t("auth.idCheckRequiredAlert", "이메일 중복확인을 먼저 해 주세요."));
        return;
    }

    if (!nicknameChecked) {
        event.preventDefault();
        alert(window.t("auth.nicknameCheckRequiredAlert", "닉네임 중복확인을 먼저 해 주세요."));
        return;
    }

    if (password !== passwordConfirm) {
        event.preventDefault();
        alert(window.t("auth.passwordMismatchAlert", "비밀번호가 서로 일치하지 않습니다."));
        return;
    }

    if (password.length < 6) {
        event.preventDefault();
        alert(window.t("auth.passwordTooShortAlert", "비밀번호는 6자 이상이어야 합니다."));
        return;
    }

    if (!privacyAgree) {
        event.preventDefault();
        alert(window.t("auth.privacyRequiredJoinAlert", "개인정보 수집·이용에 동의해야 가입할 수 있습니다."));
    }

});
