<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%@ page import="util.EscapeUtil" %>

<%
    String contextPath = request.getContextPath();

    if (session.getAttribute("loginMember") != null) {
        response.sendRedirect(contextPath + "/main");
        return;
    }

    String msg = (String) request.getAttribute("msg");
%>

<!DOCTYPE html>
<html lang="ko">

<head>
    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>회원가입 - 여행만들기</title>

    <%@ include file="/common/css-links.jspf" %>
</head>

<body>

<% String activeNav = ""; %>
<%@ include file="/common/header.jsp" %>

<main>

    <!-- =========================
         회원가입
         "이메일"을 그대로 로그인 아이디(MEMBERS.ID)로 쓴다.
    ========================== -->

    <section class="auth-section">

        <div class="auth-layout">

            <div class="auth-visual">
                <div class="auth-visual-overlay"></div>

                <div class="auth-visual-content">
                    <p class="auth-kicker">
                        TRAVEL MAKER
                    </p>

                    <h1 data-i18n="auth.signupHeroTitle">
                        여행만들기와 함께 첫 이야기를 시작해요
                    </h1>

                    <p data-i18n="auth.signupHeroDesc">
                        가입하면 여행 이야기를 작성하고 나만의 기록을 남길 수 있어요.
                    </p>

                    <div class="auth-visual-tags" aria-hidden="true">
                        <span data-i18n="home.keyword.seoul">#서울</span>
                        <span data-i18n="home.keyword.tokyo">#도쿄</span>
                        <span data-i18n="auth.tagJeju">#제주</span>
                    </div>
                </div>
            </div>

            <div class="auth-panel">

                <div class="auth-box">

                    <div class="auth-title-area">
                        <span class="auth-title-mark">✈</span>

                        <h2 data-i18n="nav.join">회원가입</h2>

                        <p class="auth-description" data-i18n="auth.signupDesc">
                            기본 정보를 입력하고 여행만들기를 시작하세요.
                        </p>
                    </div>

                    <% if (msg != null) { %>
                    <p class="field-error"><%= EscapeUtil.html(msg) %></p>
                    <% } %>

                    <form id="signupForm"
                          method="post"
                          action="<%= contextPath %>/member/join">

                        <div class="auth-field">
                            <label for="signupNickname" data-i18n="auth.nicknameLabel">
                                닉네임
                            </label>

                            <div class="auth-field-with-button">

                                <input type="text"
                                       id="signupNickname"
                                       name="signupNickname"
                                       value="<%= EscapeUtil.html(request.getParameter("signupNickname")) %>"
                                       maxlength="12"
                                       data-i18n="auth.nicknamePlaceholder"
                                       data-i18n-attr="placeholder"
                                       placeholder="사용할 닉네임을 입력해 주세요"
                                       autocomplete="nickname">

                                <button type="button" id="nicknameCheckButton" class="filter-button" data-i18n="auth.idCheckButton">
                                    중복확인
                                </button>

                            </div>

                            <p class="field-hint" data-i18n="auth.nicknameRule">
                                특수문자·공백 없이 2~12자
                            </p>
                            <p class="field-hint" id="nicknameCheckResult"></p>
                        </div>

                        <div class="auth-field">
                            <label for="signupEmail" data-i18n="auth.emailLabel">
                                이메일
                            </label>

                            <div class="auth-field-with-button">

                                <input type="email"
                                       id="signupEmail"
                                       name="signupEmail"
                                       value="<%= EscapeUtil.html(request.getParameter("signupEmail")) %>"
                                       data-i18n="auth.emailPlaceholder"
                                       data-i18n-attr="placeholder"
                                       placeholder="이메일을 입력해 주세요"
                                       autocomplete="username">

                                <button type="button" id="idCheckButton" class="filter-button" data-i18n="auth.idCheckButton">
                                    중복확인
                                </button>

                            </div>

                            <p class="field-hint" id="idCheckResult"></p>
                        </div>

                        <div class="auth-field">
                            <label for="signupPassword" data-i18n="auth.passwordLabel">
                                비밀번호
                            </label>

                            <div class="password-field-wrap">

                                <input type="password"
                                       id="signupPassword"
                                       name="signupPassword"
                                       data-i18n="auth.passwordMinPlaceholder"
                                       data-i18n-attr="placeholder"
                                       placeholder="6자 이상 입력해 주세요"
                                       autocomplete="new-password">

                                <button type="button"
                                        class="password-toggle-button"
                                        id="signupPasswordToggle"
                                        data-i18n="auth.passwordToggleAriaLabel"
                                        data-i18n-attr="aria-label"
                                        aria-label="눌러서 비밀번호 보기">
                                    👁
                                </button>

                            </div>
                        </div>

                        <div class="auth-field">
                            <label for="signupPasswordConfirm" data-i18n="auth.passwordConfirmLabel">
                                비밀번호 확인
                            </label>

                            <div class="password-field-wrap">

                                <input type="password"
                                       id="signupPasswordConfirm"
                                       name="signupPasswordConfirm"
                                       data-i18n="auth.passwordConfirmPlaceholder"
                                       data-i18n-attr="placeholder"
                                       placeholder="비밀번호를 다시 입력해 주세요"
                                       autocomplete="new-password">

                                <button type="button"
                                        class="password-toggle-button"
                                        id="signupPasswordConfirmToggle"
                                        data-i18n="auth.passwordToggleAriaLabel"
                                        data-i18n-attr="aria-label"
                                        aria-label="눌러서 비밀번호 보기">
                                    👁
                                </button>

                            </div>

                            <p class="field-hint" id="passwordMatchResult"></p>
                        </div>

                        <!-- 랭킹 화면(성별/여행지별 인기 통계)에 쓸 값. JS가 hidden input에 채워서 보낸다 -->
                        <input type="hidden" id="genderInput" name="gender" value="">

                        <div class="auth-field">
                            <label data-i18n="mypage.genderLabel">
                                성별
                            </label>

                            <div class="filter-group" id="signupGenderGroup">
                                <button type="button" class="filter-button" data-gender="M" data-i18n="gender.male">남성</button>
                                <button type="button" class="filter-button" data-gender="F" data-i18n="gender.female">여성</button>
                            </div>
                        </div>

                        <div class="auth-field auth-agree-field">
                            <label class="auth-agree-label">
                                <input type="checkbox"
                                       id="privacyAgree"
                                       name="privacyAgree"
                                       value="Y">

                                <span>
                                    <span data-i18n="editProfile.privacyRequired">[필수]</span> <a href="<%= contextPath %>/privacy" target="_blank" data-i18n="editProfile.privacyLinkText">개인정보 수집·이용</a><span data-i18n="editProfile.privacyAgreeSuffix">에 동의합니다.</span>
                                </span>
                            </label>
                        </div>

                        <button type="submit"
                                class="auth-submit"
                                data-i18n="nav.join">
                            회원가입
                        </button>

                    </form>

                    <div class="auth-divider">
                        <span>TRAVEL COMMUNITY</span>
                    </div>

                    <div class="auth-links">
                        <a href="<%= contextPath %>/member/login" data-i18n="nav.login">로그인</a>
                        <span aria-hidden="true"></span>
                        <a href="<%= contextPath %>/main" data-i18n="auth.backToMain">메인으로 돌아가기</a>
                    </div>

                </div>

            </div>

        </div>

    </section>

</main>

<%@ include file="/common/footer.jsp" %>

<script>
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

    /*
     * 비밀번호 보기 - 아이콘에 마우스를 올리고 있거나(hover) 누르고 있는 동안만
     * 평문으로 보여주고, 떼면(또는 마우스가 벗어나면) 다시 가린다. 포인터 이벤트라
     * 마우스/터치 둘 다 같은 핸들러로 처리된다.
     */

    function bindPasswordReveal(buttonId, inputId) {

        const button = document.getElementById(buttonId);
        const input = document.getElementById(inputId);

        function reveal() { input.type = "text"; }
        function hide() { input.type = "password"; }

        //mousedown 시점에 버튼이 포커스를 가져가 input의 커서 위치가 흐트러지는 걸 막는다.
        button.addEventListener("pointerdown", function (event) {
            event.preventDefault();
            reveal();
        });

        button.addEventListener("pointerenter", reveal);
        button.addEventListener("pointerup", hide);
        button.addEventListener("pointerleave", hide);
        button.addEventListener("pointercancel", hide);
    }

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

        fetch("<%= contextPath %>/member/idCheck?id=" + encodeURIComponent(email))
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

        fetch("<%= contextPath %>/member/nicknameCheck?nickname=" + encodeURIComponent(nickname))
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
</script>

</body>
</html>
