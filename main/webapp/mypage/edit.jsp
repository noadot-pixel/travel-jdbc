<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%@ page import="model.MemberDTO" %>
<%@ page import="util.EscapeUtil" %>

<%
    String contextPath = request.getContextPath();

    MemberDTO loginMember = (MemberDTO) session.getAttribute("loginMember");

    if (loginMember == null) {
        response.sendRedirect(contextPath + "/member/login");
        return;
    }

    String msg = (String) request.getAttribute("msg");

    //실패해서 다시 돌아온 경우에는 방금 입력했던 값을, 처음 들어온 경우에는 세션의 현재 값을 보여준다.
    boolean isResubmit = request.getParameter("profileNickname") != null;

    String nicknameValue = isResubmit ? request.getParameter("profileNickname") : loginMember.getNickname();
    String bioValue = isResubmit ? request.getParameter("profileBio") : loginMember.getBio();
    String countryValue = isResubmit ? request.getParameter("profileCountry") : loginMember.getCountry();
    String countryOtherValue = isResubmit ? request.getParameter("profileCountryOther") : loginMember.getCountryOther();
    String nameValue = isResubmit ? request.getParameter("profileName") : loginMember.getRealName();
    boolean namePublicValue = isResubmit ? !"private".equals(request.getParameter("nameVisibility")) : loginMember.isNamePublic();

    if (countryValue == null || countryValue.isEmpty()) countryValue = "KR";
    if (bioValue == null) bioValue = "";
    if (countryOtherValue == null) countryOtherValue = "";
    if (nameValue == null) nameValue = "";
%>

<!DOCTYPE html>
<html lang="ko" <%= (loginMember != null && loginMember.isDarkMode()) ? "data-theme=\"dark\"" : "" %>>

<head>
    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>회원정보 수정 - 여행만들기</title>

    <%@ include file="/common/css-links.jspf" %>
</head>

<body>

<% String activeNav = ""; %>
<%@ include file="/common/header.jsp" %>

<main>

    <section class="page-heading">

        <p class="breadcrumb">
            <a href="<%= contextPath %>/main" data-i18n="nav.home">홈</a>
            〉 <a href="<%= contextPath %>/member/mypage" data-i18n="mypage.title">마이페이지</a>
            〉 <span data-i18n="editProfile.breadcrumb">회원정보 수정</span>
        </p>

        <h1 data-i18n="editProfile.heading">회원정보 수정</h1>

        <p class="page-description" data-i18n="editProfile.pageDesc">
            내 프로필 정보를 수정하세요.
        </p>

    </section>

    <% if (msg != null) { %>
    <p class="field-error"><%= EscapeUtil.html(msg) %></p>
    <% } %>

    <section class="write-section mypage-section">

        <form id="profileForm"
              method="post"
              enctype="multipart/form-data"
              action="<%= contextPath %>/member/mypageEdit">

            <div class="write-field">

                <label for="profilePhoto" data-i18n="editProfile.photoLabel">
                    프로필 이미지
                </label>

                <div class="profile-photo-field">

                    <img id="profilePhotoPreview"
                         class="profile-photo-preview"
                         src="<%= loginMember.getPhotoPath() != null ? (contextPath + "/" + loginMember.getPhotoPath()) : (contextPath + "/images/logo.png") %>"
                         data-i18n="editProfile.photoPreviewAlt"
                         data-i18n-attr="alt"
                         alt="프로필 이미지 미리보기">

                    <input type="file"
                           id="profilePhoto"
                           name="profilePhoto"
                           accept="image/*">

                </div>

                <p class="write-field-note" data-i18n="editProfile.photoNote">
                    10MB 이하 이미지 파일만 업로드할 수 있습니다.
                </p>

            </div>

            <div class="write-field">

                <label for="profileNickname" data-i18n="editProfile.nicknameLabel">
                    닉네임
                </label>

                <div class="auth-field-with-button">

                    <input type="text"
                           id="profileNickname"
                           name="profileNickname"
                           value="<%= EscapeUtil.html(nicknameValue) %>"
                           maxlength="12">

                    <button type="button" id="nicknameCheckButton" class="filter-button" data-i18n="auth.idCheckButton">
                        중복확인
                    </button>

                </div>

                <p class="write-field-note" data-i18n="auth.nicknameRule">
                    특수문자·공백 없이 2~12자
                </p>
                <p class="write-field-note" id="nicknameCheckResult"></p>

            </div>

            <div class="write-field">

                <label for="profileBio" data-i18n="editProfile.bioLabel">
                    자기소개
                </label>

                <textarea id="profileBio"
                          name="profileBio"
                          rows="4"
                          data-i18n="editProfile.bioPlaceholder"
                          data-i18n-attr="placeholder"
                          placeholder="자신을 간단히 소개해 주세요"><%= EscapeUtil.html(bioValue) %></textarea>

            </div>

            <div class="write-field">

                <label for="profileCountry" data-i18n="mypage.countryLabel">
                    국가
                </label>

                <select id="profileCountry" name="profileCountry">
                    <option value="KR" data-i18n="filter.korea" <%= "KR".equals(countryValue) ? "selected" : "" %>>한국</option>
                    <option value="JP" data-i18n="filter.japan" <%= "JP".equals(countryValue) ? "selected" : "" %>>일본</option>
                    <option value="ETC" data-i18n="editProfile.countryOther" <%= "ETC".equals(countryValue) ? "selected" : "" %>>기타</option>
                </select>

            </div>

            <div class="write-field"
                 id="profileCountryOtherField"
                 <%= "ETC".equals(countryValue) ? "" : "hidden" %>>

                <label for="profileCountryOther" data-i18n="editProfile.countryOtherLabel">
                    국가 직접 입력
                </label>

                <input type="text"
                       id="profileCountryOther"
                       name="profileCountryOther"
                       value="<%= EscapeUtil.html(countryOtherValue) %>"
                       data-i18n="editProfile.countryOtherPlaceholder"
                       data-i18n-attr="placeholder"
                       placeholder="국가를 입력해 주세요">

            </div>

            <div class="mypage-personal-section">

                <p class="filter-label" data-i18n="editProfile.personalInfo">개인정보</p>

                <% if (loginMember.getGender() == null) { %>

                <p class="write-field-note" data-i18n="editProfile.genderNote">
                    성별은 성별/여행지별 인기 게시글 통계(랭킹)에 쓰이며, 한 번 저장하면
                    이 화면에서 다시 바꿀 수 없습니다. 공개 여부는 자유롭게 선택하세요.
                </p>

                <input type="hidden" id="genderInput" name="gender" value="">

                <div class="write-field">

                    <label data-i18n="mypage.genderLabel">성별</label>

                    <div class="filter-group" id="profileGenderGroup">
                        <button type="button" class="filter-button" data-gender="M" data-i18n="gender.male">남성</button>
                        <button type="button" class="filter-button" data-gender="F" data-i18n="gender.female">여성</button>
                    </div>

                    <div class="radio-group">

                        <label class="radio-option">
                            <input type="radio" name="genderVisibility" value="public" checked>
                            <span data-i18n="mypage.public">공개</span>
                        </label>

                        <label class="radio-option">
                            <input type="radio" name="genderVisibility" value="private">
                            <span data-i18n="mypage.private">비공개</span>
                        </label>

                    </div>

                </div>

                <div class="write-field">
                    <label class="auth-agree-label">
                        <input type="checkbox" id="privacyAgree" name="privacyAgree" value="Y">
                        <span>
                            <span data-i18n="editProfile.privacyRequired">[필수]</span> <a href="<%= contextPath %>/privacy" target="_blank" data-i18n="editProfile.privacyLinkText">개인정보 수집·이용</a><span data-i18n="editProfile.privacyAgreeSuffix">에 동의합니다.</span>
                        </span>
                    </label>
                </div>

                <% } %>

                <div class="write-field">

                    <label for="profileName" data-i18n="mypage.nameLabel">
                        이름
                    </label>

                    <input type="text"
                           id="profileName"
                           name="profileName"
                           value="<%= EscapeUtil.html(nameValue) %>"
                           data-i18n="editProfile.namePlaceholder"
                           data-i18n-attr="placeholder"
                           placeholder="이름을 입력해 주세요">

                    <div class="radio-group">

                        <label class="radio-option">
                            <input type="radio" name="nameVisibility" value="public" <%= namePublicValue ? "checked" : "" %>>
                            <span data-i18n="mypage.public">공개</span>
                        </label>

                        <label class="radio-option">
                            <input type="radio" name="nameVisibility" value="private" <%= namePublicValue ? "" : "checked" %>>
                            <span data-i18n="mypage.private">비공개</span>
                        </label>

                    </div>

                </div>

            </div>

            <button type="submit" class="auth-submit" data-i18n="editProfile.save">
                저장하기
            </button>

        </form>

    </section>

</main>

<%@ include file="/common/footer.jsp" %>

<script>
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

        const originalNickname = "<%= EscapeUtil.json(nicknameValue) %>";
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

            fetch("<%= contextPath %>/member/nicknameCheck?nickname=" + encodeURIComponent(nickname))
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
</script>

<% if (loginMember.getGender() == null) { %>
<script>
    /*
     * 성별 버튼 선택과, 제출 전 필수 입력 검사(서버에서도 똑같이 검사함).
     * 이 블록은 gender가 아직 null인 회원에게만 보이므로, 이 화면을 저장하려면
     * 성별/동의를 전부 채워야 한다.
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
</script>
<% } %>

</body>
</html>
