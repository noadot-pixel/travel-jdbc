<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%@ page import="java.util.List" %>
<%@ page import="model.MemberDTO" %>
<%@ page import="model.FaqDTO" %>
<%@ page import="util.EscapeUtil" %>

<%
    String contextPath = request.getContextPath();

    MemberDTO loginMember = (MemberDTO) session.getAttribute("loginMember");

    if (loginMember == null) {
        response.sendRedirect(contextPath + "/member/login");
        return;
    }

    if (!loginMember.isModerator()) {
        response.sendRedirect(contextPath + "/main");
        return;
    }

    //이 페이지는 반드시 FaqListCommand(/admin/faqs)를 거쳐서 와야 한다.
    List<FaqDTO> faqList = (List<FaqDTO>) request.getAttribute("faqList");

    if (faqList == null) {
        response.sendRedirect(contextPath + "/admin/faqs");
        return;
    }

    long adminFaqsJsVer = new java.io.File(application.getRealPath("/js/admin/faqs.js")).lastModified();
%>

<!DOCTYPE html>
<html lang="ko" <%= (loginMember != null && loginMember.isDarkMode()) ? "data-theme=\"dark\"" : "" %>>

<head>
    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>FAQ 관리 - 여행만들기</title>

    <%@ include file="/common/css-links.jspf" %>
</head>

<body>

<% String activeNav = ""; %>
<%@ include file="/common/header.jsp" %>

<main>

    <section class="page-heading">

        <p class="breadcrumb">
            <a href="<%= contextPath %>/main" data-i18n="nav.home">홈</a>
            〉 <a href="<%= contextPath %>/admin" data-i18n="nav.admin">관리자</a>
            〉 <span data-i18n="admin.menuFaqsTitle">FAQ 관리</span>
        </p>

        <h1 data-i18n="adminFaqs.heading">자주 묻는 질문 관리</h1>

        <p class="page-description">
            <span data-i18n="adminFaqs.pageDescPrefix">등록한 질문/답변은</span> <a href="<%= contextPath %>/support#faq" data-i18n="adminFaqs.supportPageLink">문의하기 페이지</a><span data-i18n="adminFaqs.pageDescSuffix">의 "자주 묻는 질문"에 바로 표시됩니다.</span>
        </p>

    </section>

    <section class="write-section">

        <form id="faqForm">

            <div class="write-field">
                <label for="faqQuestion" data-i18n="adminFaqs.questionLabel">질문</label>
                <input type="text" id="faqQuestion" data-i18n="adminFaqs.questionPlaceholder" data-i18n-attr="placeholder" placeholder="질문을 입력해 주세요">
            </div>

            <div class="write-field">
                <label for="faqAnswer" data-i18n="adminFaqs.answerLabel">답변</label>
                <textarea id="faqAnswer" rows="3" data-i18n="adminFaqs.answerPlaceholder" data-i18n-attr="placeholder" placeholder="답변을 입력해 주세요"></textarea>
            </div>

            <button type="submit" class="auth-submit" data-i18n="write.submit">등록하기</button>

        </form>

    </section>

    <section class="admin-faq-list-section">

        <% if (faqList.isEmpty()) { %>
        <p class="ranking-empty" data-i18n="support.noFaq">등록된 FAQ가 없습니다.</p>
        <% } else { %>
        <ul class="admin-faq-list">
            <% for (FaqDTO faq : faqList) { %>
            <li class="admin-faq-item" data-faq-id="<%= faq.getFaqId() %>">

                <div class="admin-faq-view">

                    <div class="admin-faq-item-head">
                        <strong>Q. <%= EscapeUtil.html(faq.getQuestion()) %></strong>
                        <span><%= faq.getRegDate() %> · <%= EscapeUtil.html(faq.getWriterNick()) %></span>
                    </div>

                    <p>A. <%= EscapeUtil.html(faq.getAnswer()) %></p>

                    <div class="admin-faq-actions">
                        <button type="button" class="admin-faq-edit-button" data-i18n="common.edit">수정</button>
                        <button type="button" class="admin-faq-delete-button" data-i18n="common.delete">삭제</button>
                    </div>

                </div>

                <div class="admin-faq-edit-form" hidden>

                    <div class="write-field">
                        <input type="text" class="admin-faq-edit-question" value="<%= EscapeUtil.html(faq.getQuestion()) %>">
                    </div>

                    <div class="write-field">
                        <textarea rows="3" class="admin-faq-edit-answer"><%= EscapeUtil.html(faq.getAnswer()) %></textarea>
                    </div>

                    <div class="admin-faq-actions">
                        <button type="button" class="auth-submit admin-faq-save-button" data-i18n="adminFaqs.save">저장</button>
                        <button type="button" class="admin-faq-cancel-button" data-i18n="adminFaqs.cancel">취소</button>
                    </div>

                </div>

            </li>
            <% } %>
        </ul>
        <% } %>

    </section>

</main>

<%@ include file="/common/footer.jsp" %>

<script src="<%= contextPath %>/js/admin/faqs.js?v=<%= adminFaqsJsVer %>"></script>

</body>
</html>
