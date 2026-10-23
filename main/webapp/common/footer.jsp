<%@ page pageEncoding="UTF-8" %>
<%--
    공통 푸터. 사용하는 페이지는 include 전에 아래 변수를 선언해야 한다.

        String contextPath = request.getContextPath();
--%>
<%
    //헤더와 같은 이유(Cloudflare 캐시 우회)로 로고 버전을 따로 계산한다 - header.jsp와는
    //별개 include라서 거기서 만든 headerLogoJaVer를 그대로 쓸 수 없다.
    long footerLogoJaVer = new java.io.File(application.getRealPath("/images/logo_ja.png")).lastModified();
    long footerJsVer = new java.io.File(application.getRealPath("/js/common/footer.js")).lastModified();
%>

<footer class="footer">

    <div class="footer-inner">

        <div class="footer-logo-area">

            <a href="<%= contextPath %>/main"
               class="bottom-logo">

                <img src="<%= contextPath %>/images/logo_ja.png?v=<%= footerLogoJaVer %>"
                     alt="여행만들기 로고"
                     class="brand-logo-image"
                     data-i18n="brand.logoAlt"
                     data-i18n-attr="alt">
            </a>

            <p data-i18n="footer.tagline">
                함께 만드는, 더 넓은 여행의 세상
            </p>

        </div>

        <div class="footer-menu">

            <strong data-i18n="home.footerVisual.webTitle">여행만들기</strong>

            <a href="https://noadot-pixel.github.io/travel-portfolio/" target="_blank" rel="noopener" data-i18n="footer.about">소개</a>
            <a href="<%= contextPath %>/privacy" data-i18n="footer.privacy">개인정보처리방침</a>

        </div>

        <div class="footer-menu">

            <strong data-i18n="footer.support">고객지원</strong>

            <a href="<%= contextPath %>/notice/list" data-i18n="footer.notices">공지사항</a>
            <a href="<%= contextPath %>/support#faq" data-i18n="footer.faq">자주 묻는 질문</a>
            <a href="<%= contextPath %>/support#contact" data-i18n="footer.contact">문의하기</a>

        </div>

    </div>

    <p class="copyright">
        <span data-i18n="footer.copyright">© 2026 여행만들기. All rights reserved.</span>
    </p>

</footer>

<script src="<%= contextPath %>/js/common/footer.js?v=<%= footerJsVer %>"></script>
