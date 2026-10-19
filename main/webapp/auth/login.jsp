<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%@ page import="model.MemberDTO" %>
<%@ page import="util.EscapeUtil" %>

<%
    String contextPath = request.getContextPath();

    if (session.getAttribute("loginMember") != null) {
        response.sendRedirect(contextPath + "/main");
        return;
    }

    String msg = (String) request.getAttribute("msg");           // 로그인 실패 메시지 (LoginCommand)
    String inputId = (String) request.getAttribute("inputId");   // 실패 시 입력했던 이메일
    boolean joined = "1".equals(request.getParameter("joined"));  // 회원가입 직후 이동해 온 경우 (JoinCommand)
%>

<!DOCTYPE html>
<html lang="ko">

<head>
    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>로그인 - 여행만들기</title>

    <%@ include file="/common/css-links.jspf" %>
</head>

<body>

<% String activeNav = ""; %>
<%@ include file="/common/header.jsp" %>

<main>

    <!-- =========================
         로그인
         MEMBERS 테이블에서 이메일(id)/비밀번호가 맞는 회원을 찾아 세션에 저장한다.
    ========================== -->

    <section class="auth-section">

        <div class="auth-layout">

            <div class="auth-visual">
                <div class="auth-visual-overlay"></div>

                <div class="auth-visual-content">
                    <p class="auth-kicker">
                        TRAVEL MAKER
                    </p>

                    <h1 data-i18n="auth.loginHeroTitle">
                        다시 여행을 이어가 볼까요?
                    </h1>

                    <p data-i18n="auth.loginHeroDesc">
                        여행 기록을 남기고, 새로운 여행 이야기를 만나보세요.
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

                        <h2 data-i18n="nav.login">로그인</h2>

                        <p class="auth-description" data-i18n="auth.loginDesc">
                            여행만들기 계정으로 로그인하세요.
                        </p>
                    </div>

                    <% if (joined) { %>
                    <p class="field-msg" data-i18n="auth.joinedMsg">회원가입이 완료되었습니다. 로그인해 주세요.</p>
                    <% } %>

                    <% if (msg != null) { %>
                    <p class="field-error"><%= EscapeUtil.html(msg) %></p>
                    <% } %>

                    <form id="loginForm"
                          method="post"
                          action="<%= contextPath %>/member/login">

                        <div class="auth-field">
                            <label for="loginEmail" data-i18n="auth.emailLabel">
                                이메일
                            </label>

                            <input type="email"
                                   id="loginEmail"
                                   name="loginEmail"
                                   value="<%= EscapeUtil.html(inputId) %>"
                                   data-i18n="auth.emailPlaceholder"
                                   data-i18n-attr="placeholder"
                                   placeholder="이메일을 입력해 주세요"
                                   autocomplete="username">
                        </div>

                        <div class="auth-field">
                            <label for="loginPassword" data-i18n="auth.passwordLabel">
                                비밀번호
                            </label>

                            <input type="password"
                                   id="loginPassword"
                                   name="loginPassword"
                                   data-i18n="auth.passwordPlaceholder"
                                   data-i18n-attr="placeholder"
                                   placeholder="비밀번호를 입력해 주세요"
                                   autocomplete="current-password">
                        </div>

                        <button type="submit"
                                class="auth-submit"
                                data-i18n="nav.login">
                            로그인
                        </button>

                    </form>

                    <div class="auth-divider">
                        <span>TRAVEL COMMUNITY</span>
                    </div>

                    <div class="auth-links">
                        <a href="<%= contextPath %>/member/join" data-i18n="nav.join">회원가입</a>
                        <span aria-hidden="true"></span>
                        <a href="<%= contextPath %>/main" data-i18n="auth.backToMain">메인으로 돌아가기</a>
                    </div>

                </div>

            </div>

        </div>

    </section>

</main>

<%@ include file="/common/footer.jsp" %>

</body>
</html>
