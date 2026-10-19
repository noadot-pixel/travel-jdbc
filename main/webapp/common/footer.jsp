<%@ page pageEncoding="UTF-8" %>
<%--
    공통 푸터. 사용하는 페이지는 include 전에 아래 변수를 선언해야 한다.

        String contextPath = request.getContextPath();
--%>

<footer class="footer">

    <div class="footer-inner">

        <div class="footer-logo-area">

            <a href="<%= contextPath %>/main"
               class="bottom-logo">

                <img src="<%= contextPath %>/images/logo.png"
                     alt="여행만들기 로고">
            </a>

            <p data-i18n="footer.tagline">
                함께 만드는, 더 넓은 여행의 세상
            </p>

        </div>

        <div class="footer-menu">

            <strong>여행만들기</strong>

            <a href="<%= contextPath %>/about" data-i18n="footer.about">소개</a>
            <a href="#" class="footer-placeholder-link" data-i18n="footer.terms" data-message="이용약관 페이지는 준비 중입니다.">이용약관</a>
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

<script>
    document.querySelectorAll(".footer-placeholder-link").forEach(function (link) {

        link.addEventListener("click", function (event) {

            event.preventDefault();

            alert(link.dataset.message);

        });

    });
</script>
