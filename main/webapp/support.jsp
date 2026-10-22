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

    long supportJsVer = new java.io.File(application.getRealPath("/js/support.js")).lastModified();

    String keyword = (String) request.getAttribute("keyword");
    if (keyword == null) keyword = "";
%>

<!DOCTYPE html>
<html lang="ko" <%= (loginMember != null && loginMember.isDarkMode()) ? "data-theme=\"dark\"" : "" %>>

<head>
    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title data-i18n="title.support">자주 묻는 질문 · 문의하기 - 여행만들기</title>

    <%@ include file="/common/css-links.jspf" %>
</head>

<body>

<% String activeNav = ""; %>
<%@ include file="/common/header.jsp" %>

<main>

    <section class="page-heading" id="faq">

        <p class="breadcrumb">
            <a href="<%= contextPath %>/main" data-i18n="nav.home">홈</a>
            〉 <span data-i18n="support.breadcrumb">자주 묻는 질문 · 문의하기</span>
        </p>

        <h1 data-i18n="footer.faq">자주 묻는 질문</h1>

        <p class="page-description" data-i18n="support.faqPageDesc">
            자주 나오는 질문을 먼저 확인해 보세요. 찾는 답이 없다면 아래에서 바로 문의할 수 있습니다.
        </p>

    </section>

    <section class="faq-section">

        <% if (faqList.isEmpty()) { %>
        <p class="ranking-empty" data-i18n="support.noFaq">등록된 FAQ가 없습니다.</p>
        <% } else { %>
        <ul class="faq-list">
            <% for (FaqDTO faq : faqList) { %>
            <li class="faq-item">

                <button type="button" class="faq-question">
                    <span>Q. <%= EscapeUtil.html(faq.getQuestion()) %></span>
                    <span class="faq-toggle-icon">+</span>
                </button>

                <p class="faq-answer" hidden><%= EscapeUtil.html(faq.getAnswer()) %></p>

            </li>
            <% } %>
        </ul>
        <% } %>

    </section>

    <section class="page-heading" id="contact">

        <h1 data-i18n="support.contactHeading">문의하기</h1>

        <p class="page-description" data-i18n="support.contactPageDesc">
            궁금한 점을 남겨주시면 다른 분들도 함께 볼 수 있어요.
        </p>

    </section>

    <% if (msg != null) { %>
    <p class="field-error"><%= EscapeUtil.html(msg) %></p>
    <% } %>

    <section class="write-section">

        <% if (loginMember == null) { %>

        <p class="write-field-note">
            <span data-i18n="support.loginRequiredPrefix">문의를 남기려면</span> <a href="<%= contextPath %>/member/login" data-i18n="nav.login">로그인</a><span data-i18n="support.loginRequiredSuffix">이 필요합니다.</span>
        </p>

        <% } else { %>

        <form id="inquiryForm"
              method="post"
              action="<%= contextPath %>/support/write">

            <div class="write-field">
                <label for="inquiryTitle" data-i18n="write.titleLabel">제목</label>
                <input type="text"
                       id="inquiryTitle"
                       name="title"
                       data-i18n="support.inquiryTitlePlaceholder"
                       data-i18n-attr="placeholder"
                       placeholder="문의 제목을 입력해 주세요">
            </div>

            <div class="write-field">
                <label for="inquiryContent" data-i18n="support.contentLabel">내용</label>
                <textarea id="inquiryContent"
                          name="content"
                          rows="4"
                          data-i18n="support.inquiryContentPlaceholder"
                          data-i18n-attr="placeholder"
                          placeholder="문의 내용을 입력해 주세요"></textarea>
            </div>

            <div class="write-field">
                <label class="auth-agree-label">
                    <input type="checkbox" id="inquiryPrivate" name="isPrivate" value="Y">
                    <span data-i18n="support.privateCheckbox">비공개로 남기기 (나와 관리자만 볼 수 있어요)</span>
                </label>
            </div>

            <button type="submit" class="auth-submit" data-i18n="support.submitInquiry">문의 남기기</button>

        </form>

        <% } %>

    </section>

    <section class="inquiry-list-section">

        <form class="search-form inquiry-search-form" action="<%= contextPath %>/support#contact" method="get">

            <label for="inquirySearchKeyword" class="blind" data-i18n="support.searchLabel">문의 검색</label>

            <input type="text"
                   id="inquirySearchKeyword"
                   name="keyword"
                   value="<%= EscapeUtil.html(keyword) %>"
                   data-i18n="support.searchPlaceholder"
                   data-i18n-attr="placeholder"
                   placeholder="문의 제목/내용으로 검색해 보세요">

            <button type="submit" data-i18n="common.search">검색</button>

        </form>

        <% if (inquiryList.isEmpty()) { %>
        <p class="ranking-empty" data-i18n="support.noInquiries">등록된 문의가 없습니다.</p>
        <% } else { %>
        <ul class="inquiry-list">
            <% for (InquiryDTO inquiry : inquiryList) { %>
            <li class="inquiry-item">

                <a class="inquiry-item-link" href="<%= contextPath %>/support/view?inquiryId=<%= inquiry.getInquiryId() %>">

                    <div class="inquiry-item-head">
                        <strong><%= EscapeUtil.html(inquiry.getTitle()) %></strong>
                        <% if (inquiry.isPrivate()) { %>
                        <span class="inquiry-private-badge" data-i18n="mypage.private">비공개</span>
                        <% } %>
                        <span><%= inquiry.getRegDate() %> · <%= EscapeUtil.html(inquiry.getWriterNick()) %></span>
                    </div>

                </a>

            </li>
            <% } %>
        </ul>
        <% } %>

    </section>

</main>

<%@ include file="/common/footer.jsp" %>

<script src="<%= contextPath %>/js/support.js?v=<%= supportJsVer %>"></script>

</body>
</html>
