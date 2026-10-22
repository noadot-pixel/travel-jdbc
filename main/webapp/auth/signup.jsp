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

    long passwordRevealJsVer = new java.io.File(application.getRealPath("/js/common/password-reveal.js")).lastModified();
    long signupJsVer = new java.io.File(application.getRealPath("/js/auth/signup.js")).lastModified();
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

<script src="<%= contextPath %>/js/common/password-reveal.js?v=<%= passwordRevealJsVer %>"></script>
<script src="<%= contextPath %>/js/auth/signup.js?v=<%= signupJsVer %>"></script>

</body>
</html>
