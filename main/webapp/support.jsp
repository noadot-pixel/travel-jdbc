<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%@ page import="java.util.List" %>
<%@ page import="model.FaqDTO" %>
<%@ page import="model.InquiryDTO" %>
<%@ page import="model.MemberDTO" %>
<%@ page import="util.EscapeUtil" %>

<%
    String contextPath = request.getContextPath();

    MemberDTO loginMember = (MemberDTO) session.getAttribute("loginMember");

    //이 페이지는 반드시 SupportController(/support)를 거쳐서 와야 한다.
    List<FaqDTO> faqList = (List<FaqDTO>) request.getAttribute("faqList");
    List<InquiryDTO> inquiryList = (List<InquiryDTO>) request.getAttribute("inquiryList");

    if (faqList == null || inquiryList == null) {
        response.sendRedirect(contextPath + "/support");
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

    <title>자주 묻는 질문 · 문의하기 - 여행만들기</title>

    <%@ include file="/common/css-links.jspf" %>
</head>

<body>

<% String activeNav = ""; %>
<%@ include file="/common/header.jsp" %>

<main>

    <section class="page-heading" id="faq">

        <p class="breadcrumb">
            <a href="<%= contextPath %>/main">홈</a>
            〉 자주 묻는 질문 · 문의하기
        </p>

        <h1>자주 묻는 질문</h1>

        <p class="page-description">
            자주 나오는 질문을 먼저 확인해 보세요. 찾는 답이 없다면 아래에서 바로 문의할 수 있습니다.
        </p>

    </section>

    <section class="faq-section">

        <% if (faqList.isEmpty()) { %>
        <p class="ranking-empty">등록된 FAQ가 없습니다.</p>
        <% } else { %>
        <ul class="faq-list">
            <% for (FaqDTO faq : faqList) { %>
            <li class="faq-item">

                <button type="button" class="faq-question">
                    <span>Q. <%= EscapeUtil.html(faq.getQuestion()) %></span>
                    <span class="faq-toggle-icon">+</span>
                </button>

                <p class="faq-answer" hidden>
                    <%= EscapeUtil.html(faq.getAnswer()) %>
                </p>

            </li>
            <% } %>
        </ul>
        <% } %>

    </section>

    <section class="page-heading" id="contact">

        <h1>문의하기</h1>

        <p class="page-description">
            궁금한 점을 남겨주시면 다른 분들도 함께 볼 수 있어요.
        </p>

    </section>

    <% if (msg != null) { %>
    <p class="field-error"><%= EscapeUtil.html(msg) %></p>
    <% } %>

    <section class="write-section">

        <% if (loginMember == null) { %>

        <p class="write-field-note">
            문의를 남기려면 <a href="<%= contextPath %>/member/login">로그인</a>이 필요합니다.
        </p>

        <% } else { %>

        <form id="inquiryForm"
              method="post"
              action="<%= contextPath %>/support/write">

            <div class="write-field">
                <label for="inquiryTitle">제목</label>
                <input type="text"
                       id="inquiryTitle"
                       name="title"
                       placeholder="문의 제목을 입력해 주세요">
            </div>

            <div class="write-field">
                <label for="inquiryContent">내용</label>
                <textarea id="inquiryContent"
                          name="content"
                          rows="4"
                          placeholder="문의 내용을 입력해 주세요"></textarea>
            </div>

            <button type="submit" class="auth-submit">문의 남기기</button>

        </form>

        <% } %>

    </section>

    <section class="inquiry-list-section">

        <% if (inquiryList.isEmpty()) { %>
        <p class="ranking-empty">등록된 문의가 없습니다.</p>
        <% } else { %>
        <ul class="inquiry-list">
            <% for (InquiryDTO inquiry : inquiryList) { %>
            <li class="inquiry-item">

                <div class="inquiry-item-head">
                    <strong><%= EscapeUtil.html(inquiry.getTitle()) %></strong>
                    <span><%= inquiry.getRegDate() %> · <%= EscapeUtil.html(inquiry.getWriterNick()) %></span>
                </div>

                <p><%= EscapeUtil.html(inquiry.getContent()) %></p>

            </li>
            <% } %>
        </ul>
        <% } %>

    </section>

</main>

<%@ include file="/common/footer.jsp" %>

<script>
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
</script>

</body>
</html>
