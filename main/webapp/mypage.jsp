<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%@ page import="java.util.List" %>
<%@ page import="model.MemberDTO" %>
<%@ page import="model.PostDTO" %>
<%@ page import="util.EscapeUtil" %>

<%
    String contextPath = request.getContextPath();

    MemberDTO loginMember = (MemberDTO) session.getAttribute("loginMember");

    if (loginMember == null) {
        response.sendRedirect(contextPath + "/member/login");
        return;
    }

    //이 페이지는 반드시 MypageCommand(/member/mypage)를 거쳐서 와야 한다.
    String activityType = (String) request.getAttribute("activityType");

    if (activityType == null) {
        response.sendRedirect(contextPath + "/member/mypage");
        return;
    }

    List<PostDTO> postList = (List<PostDTO>) request.getAttribute("postList");
    List<model.CommentDTO> commentList = (List<model.CommentDTO>) request.getAttribute("commentList");
    String keyword = (String) request.getAttribute("keyword");
    int pageNum = (Integer) request.getAttribute("page");
    int totalPages = (Integer) request.getAttribute("totalPages");
    int totalCount = (Integer) request.getAttribute("totalCount");

    String encodedKeyword = java.net.URLEncoder.encode(keyword, "UTF-8");
    String pageQuery = "type=" + activityType + "&keyword=" + encodedKeyword + "&page=";

    String countryLabel;
    String countryI18nKey = null;
    if ("KR".equals(loginMember.getCountry())) { countryLabel = "한국"; countryI18nKey = "filter.korea"; }
    else if ("JP".equals(loginMember.getCountry())) { countryLabel = "일본"; countryI18nKey = "filter.japan"; }
    else if ("ETC".equals(loginMember.getCountry())) countryLabel = (loginMember.getCountryOther() != null ? loginMember.getCountryOther() : "기타");
    else { countryLabel = "설정하지 않음"; countryI18nKey = "mypage.countryNotSet"; }

    long mypageJsVer = new java.io.File(application.getRealPath("/js/mypage.js")).lastModified();
%>

<!DOCTYPE html>
<html lang="ko" <%= (loginMember != null && loginMember.isDarkMode()) ? "data-theme=\"dark\"" : "" %>>

<head>
    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>마이페이지 - 여행만들기</title>

    <%@ include file="/common/css-links.jspf" %>
</head>

<body>

<% String activeNav = ""; %>
<%@ include file="/common/header.jsp" %>

<main>

    <!-- =========================
         마이페이지 (보기 전용)
         수정은 /member/mypageEdit에서 한다.
    ========================== -->

    <section class="page-heading">

        <p class="breadcrumb">
            <a href="<%= contextPath %>/main" data-i18n="nav.home">홈</a>
            〉 <span data-i18n="mypage.title">마이페이지</span>
        </p>

        <h1 data-i18n="mypage.title">마이페이지</h1>

        <p class="page-description" data-i18n="mypage.pageDesc">
            내 프로필과 내가 작성한 글을 확인하세요.
        </p>

    </section>

    <section class="profile-section">

        <div class="profile-card">

            <img class="profile-photo-large"
                 src="<%= loginMember.getPhotoPath() != null ? (contextPath + "/" + loginMember.getPhotoPath()) : (contextPath + "/images/logo.png") %>"
                 data-i18n="mypage.photoAlt"
                 data-i18n-attr="alt"
                 alt="프로필 이미지">

            <div class="profile-card-info">

                <h2><%= EscapeUtil.html(loginMember.getNickname()) %></h2>

                <p class="profile-bio"><%
                    if (loginMember.getBio() != null && !loginMember.getBio().isEmpty()) {
                        out.print(EscapeUtil.html(loginMember.getBio()));
                    } else {
                %><span data-i18n="mypage.noBio">아직 소개가 없습니다.</span><%
                    }
                %></p>

                <div class="profile-meta">
                    <span><span data-i18n="mypage.countryLabel">국가</span> <% if (countryI18nKey != null) { %><span data-i18n="<%= countryI18nKey %>"><%= EscapeUtil.html(countryLabel) %></span><% } else { %><%= EscapeUtil.html(countryLabel) %><% } %></span>
                    <span><span data-i18n="mypage.emailLabel">이메일</span> <%= EscapeUtil.html(loginMember.getId()) %></span>
                </div>

                <div class="profile-personal">
                    <%
                        java.util.List<String> personalParts = new java.util.ArrayList<String>();

                        if (loginMember.getGender() != null) {
                            String genderKey = "M".equals(loginMember.getGender()) ? "gender.male" : "gender.female";
                            personalParts.add("<span data-i18n=\"mypage.genderLabel\">성별</span> "
                                + "<span data-i18n=\"" + genderKey + "\">" + loginMember.getGenderLabel() + "</span>"
                                + " (<span data-i18n=\"" + (loginMember.isGenderPublic() ? "mypage.public" : "mypage.private") + "\">"
                                + (loginMember.isGenderPublic() ? "공개" : "비공개") + "</span>)");
                        }

                        if (loginMember.getRealName() != null && !loginMember.getRealName().isEmpty()) {
                            personalParts.add("<span data-i18n=\"mypage.nameLabel\">이름</span> " + EscapeUtil.html(loginMember.getRealName())
                                + " (<span data-i18n=\"" + (loginMember.isNamePublic() ? "mypage.public" : "mypage.private") + "\">"
                                + (loginMember.isNamePublic() ? "공개" : "비공개") + "</span>)");
                        }
                    %>
                    <%= String.join(" · ", personalParts) %>
                </div>

                <a href="<%= contextPath %>/member/mypageEdit"
                   class="auth-submit profile-edit-button"
                   data-i18n="mypage.editInfo">
                    정보 수정
                </a>

            </div>

        </div>

    </section>

    <section class="page-heading">
        <h2 data-i18n="mypage.myActivity">내 활동</h2>
    </section>

    <section class="activity-controls">

        <div class="pill-radio-wrap" id="activityTypeWrap">

            <label class="pill-radio-option <%= "post".equals(activityType) ? "active" : "" %>">
                <input type="radio" name="activityType" value="post" <%= "post".equals(activityType) ? "checked" : "" %>>
                <span data-i18n="mypage.tabPost">게시글</span>
            </label>

            <label class="pill-radio-option <%= "comment".equals(activityType) ? "active" : "" %>">
                <input type="radio" name="activityType" value="comment" <%= "comment".equals(activityType) ? "checked" : "" %>>
                <span data-i18n="detail.comments">댓글</span>
            </label>

            <label class="pill-radio-option <%= "scrap".equals(activityType) ? "active" : "" %>">
                <input type="radio" name="activityType" value="scrap" <%= "scrap".equals(activityType) ? "checked" : "" %>>
                <span data-i18n="detail.scrap">스크랩</span>
            </label>

        </div>

        <form class="search-form activity-search-form" action="<%= contextPath %>/member/mypage" method="get">

            <input type="hidden" name="type" value="<%= activityType %>">

            <label for="activitySearchKeyword" class="blind" data-i18n="mypage.searchLabel">내 활동 검색</label>

            <input type="text"
                   id="activitySearchKeyword"
                   name="keyword"
                   value="<%= EscapeUtil.html(keyword) %>"
                   data-i18n="mypage.searchPlaceholder"
                   data-i18n-attr="placeholder"
                   placeholder="내가 쓴 내용에서 검색해 보세요">

            <button type="submit" data-i18n="common.search">검색</button>

        </form>

    </section>

    <section class="list-heading">
        <p>
            <span data-i18n="mypage.totalCount">전체</span> <strong><%= totalCount %></strong><span data-i18n="common.countSuffix">개</span>
        </p>
    </section>

    <ul class="activity-list">

        <% if ("comment".equals(activityType)) {
            for (model.CommentDTO comment : commentList) { %>
        <li class="activity-item">
            <a href="<%= contextPath %>/post/view?bno=<%= comment.getBno() %>" class="activity-item-link">
                <strong class="activity-item-title"><%= EscapeUtil.html(comment.getPostTitle()) %></strong>
                <p class="activity-item-desc"><%= EscapeUtil.html(comment.getContent()) %></p>
                <span class="activity-item-date"><%= comment.getRegDate() %></span>
            </a>
            <div class="detail-actions local-post-actions">
                <form method="post" action="<%= contextPath %>/comment/delete" class="comment-remove-form"
                      onsubmit="return confirm(window.t('detail.confirmDeleteComment', '이 댓글을 삭제하시겠습니까?'));">
                    <input type="hidden" name="cno" value="<%= comment.getCno() %>">
                    <button type="submit" class="detail-delete-button" data-i18n="common.delete">삭제</button>
                </form>
            </div>
        </li>
        <% }
        } else {
            for (PostDTO post : postList) { %>
        <li class="activity-item">
            <a href="<%= contextPath %>/post/view?bno=<%= post.getBno() %>" class="activity-item-link">
                <strong class="activity-item-title"><%= EscapeUtil.html(post.getTitle()) %></strong>
                <span class="activity-item-date"><%= post.getRegDate() %> · <span data-i18n="common.viewCount">조회</span> <%= post.getViewCnt() %> · <span data-i18n="common.likeCount">좋아요</span> <%= post.getLikeCnt() %></span>
            </a>
            <div class="detail-actions local-post-actions">
                <% if ("scrap".equals(activityType)) { %>
                <form method="post" action="<%= contextPath %>/post/scrap" class="scrap-remove-form">
                    <input type="hidden" name="bno" value="<%= post.getBno() %>">
                    <button type="submit" class="detail-delete-button" data-i18n="mypage.scrapRemove">스크랩 해제</button>
                </form>
                <% } else { %>
                <a href="<%= contextPath %>/post/modify?bno=<%= post.getBno() %>" class="detail-edit-button" data-i18n="common.edit">수정</a>
                <form method="post" action="<%= contextPath %>/post/delete" onsubmit="return confirm(window.t('detail.confirmDeletePost', '이 게시글을 삭제하시겠습니까?'));">
                    <input type="hidden" name="bno" value="<%= post.getBno() %>">
                    <button type="submit" class="detail-delete-button" data-i18n="common.delete">삭제</button>
                </form>
                <% } %>
            </div>
        </li>
        <%  }
        } %>

    </ul>

    <% boolean activityEmpty = "comment".equals(activityType) ? commentList.isEmpty() : postList.isEmpty();
       if (activityEmpty) { %>
    <p class="empty-result" data-i18n="mypage.emptyResult">
        조건에 맞는 내역이 없습니다.
    </p>
    <% } %>

    <% if (totalPages > 1) {

        int windowSize = 10;
        int startPage = Math.max(1, pageNum - windowSize / 2);
        int endPage = Math.min(totalPages, startPage + windowSize - 1);
        startPage = Math.max(1, endPage - windowSize + 1);
    %>
    <section class="pagination">

        <% if (pageNum > 1) { %>
        <a class="page-button" href="<%= contextPath %>/member/mypage?<%= pageQuery %><%= pageNum - 1 %>">‹</a>
        <% } %>

        <% for (int p = startPage; p <= endPage; p++) { %>
        <a class="page-button <%= p == pageNum ? "active" : "" %>"
           href="<%= contextPath %>/member/mypage?<%= pageQuery %><%= p %>"><%= p %></a>
        <% } %>

        <% if (pageNum < totalPages) { %>
        <a class="page-button" href="<%= contextPath %>/member/mypage?<%= pageQuery %><%= pageNum + 1 %>">›</a>
        <% } %>

    </section>
    <% } %>

</main>

<%@ include file="/common/footer.jsp" %>

<script src="<%= contextPath %>/js/mypage.js?v=<%= mypageJsVer %>"></script>

</body>
</html>
