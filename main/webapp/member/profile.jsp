<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%@ page import="java.util.List" %>
<%@ page import="model.MemberDTO" %>
<%@ page import="model.PostDTO" %>
<%@ page import="util.EscapeUtil" %>

<%
    String contextPath = request.getContextPath();

    //보고 있는 사람(로그인했다면) 기준 다크모드 - 프로필 주인공(profileMember)과는 다른 사람이다.
    MemberDTO themeMember = (MemberDTO) session.getAttribute("loginMember");

    //이 페이지는 반드시 MemberProfileCommand(/member/profile)를 거쳐서 와야 한다.
    MemberDTO profileMember = (MemberDTO) request.getAttribute("profileMember");
    List<PostDTO> posts = (List<PostDTO>) request.getAttribute("posts");

    if (profileMember == null || posts == null) {
        response.sendRedirect(contextPath + "/main");
        return;
    }

    String countryLabel;
    String countryI18nKey = null;
    if ("KR".equals(profileMember.getCountry())) { countryLabel = "한국"; countryI18nKey = "filter.korea"; }
    else if ("JP".equals(profileMember.getCountry())) { countryLabel = "일본"; countryI18nKey = "filter.japan"; }
    else if ("ETC".equals(profileMember.getCountry())) countryLabel = (profileMember.getCountryOther() != null ? profileMember.getCountryOther() : "기타");
    else countryLabel = "-";

    //common/post-card.jspf가 쓰는 변수들 (다른 사람 글이니 수정/삭제 버튼은 안 보여준다)
    boolean showMyBadge = false;
    String actionsHtml = null;

    long documentTitleJsVer = new java.io.File(application.getRealPath("/js/common/document-title.js")).lastModified();
%>

<!DOCTYPE html>
<html lang="ko" <%= (themeMember != null && themeMember.isDarkMode()) ? "data-theme=\"dark\"" : "" %>>

<head>
    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title><%= EscapeUtil.html(profileMember.getNickname()) %>님의 프로필 - 여행만들기</title>

    <script>
        window.pageTitleData = {
            content: "<%= EscapeUtil.json(profileMember.getNickname()) %>",
            suffixKey: "profile.nicknameSuffix",
            suffixFallback: "님의 프로필"
        };
    </script>

    <%@ include file="/common/css-links.jspf" %>
</head>

<body>

<% String activeNav = ""; %>
<%@ include file="/common/header.jsp" %>

<main>

    <section class="page-heading">

        <p class="breadcrumb">
            <a href="<%= contextPath %>/main" data-i18n="nav.home">홈</a>
            〉 <%= EscapeUtil.html(profileMember.getNickname()) %><span data-i18n="profile.nicknameSuffix">님의 프로필</span>
        </p>

        <h1><%= EscapeUtil.html(profileMember.getNickname()) %><span data-i18n="profile.nicknameSuffix">님의 프로필</span></h1>

    </section>

    <section class="profile-section">

        <div class="profile-card">

            <img class="profile-photo-large"
                 src="<%= profileMember.getPhotoPath() != null ? (contextPath + "/" + profileMember.getPhotoPath()) : (contextPath + "/images/logo.png") %>"
                 data-i18n="mypage.photoAlt"
                 data-i18n-attr="alt"
                 alt="프로필 이미지">

            <div class="profile-card-info">

                <h2><%= EscapeUtil.html(profileMember.getNickname()) %></h2>

                <p class="profile-bio"><%
                    if (profileMember.getBio() != null && !profileMember.getBio().isEmpty()) {
                        out.print(EscapeUtil.html(profileMember.getBio()));
                    } else {
                %><span data-i18n="mypage.noBio">아직 소개가 없습니다.</span><%
                    }
                %></p>

                <div class="profile-meta">
                    <span><span data-i18n="mypage.countryLabel">국가</span> <% if (countryI18nKey != null) { %><span data-i18n="<%= countryI18nKey %>"><%= EscapeUtil.html(countryLabel) %></span><% } else { %><%= EscapeUtil.html(countryLabel) %><% } %></span>
                </div>

                <%-- 실명/성별은 그 회원이 공개로 설정했을 때만 보여준다 (비공개는 아예 표시하지 않음 -
                     본인 마이페이지와 달리 "(비공개)"라는 안내 자체가 다른 사람에겐 의미가 없다). --%>
                <div class="profile-personal">
                    <%
                        java.util.List<String> personalParts = new java.util.ArrayList<String>();

                        if (profileMember.getGender() != null && profileMember.isGenderPublic()) {
                            String genderKey = "M".equals(profileMember.getGender()) ? "gender.male" : "gender.female";
                            personalParts.add("<span data-i18n=\"mypage.genderLabel\">성별</span> "
                                + "<span data-i18n=\"" + genderKey + "\">" + profileMember.getGenderLabel() + "</span>");
                        }

                        if (profileMember.getRealName() != null && !profileMember.getRealName().isEmpty() && profileMember.isNamePublic()) {
                            personalParts.add("<span data-i18n=\"mypage.nameLabel\">이름</span> " + EscapeUtil.html(profileMember.getRealName()));
                        }
                    %>
                    <%= String.join(" · ", personalParts) %>
                </div>

            </div>

        </div>

    </section>

    <section class="page-heading">
        <h2><%= EscapeUtil.html(profileMember.getNickname()) %><span data-i18n="profile.postsSuffix">님이 작성한 글</span></h2>
    </section>

    <section class="post-list">

        <% for (PostDTO post : posts) { %>
            <%@ include file="/common/post-card.jspf" %>
        <% } %>

    </section>

    <% if (posts.isEmpty()) { %>
    <p class="empty-result" data-i18n="profile.noPostsYet">
        아직 작성한 게시글이 없습니다.
    </p>
    <% } %>

</main>

<%@ include file="/common/footer.jsp" %>
<script src="<%= contextPath %>/js/common/document-title.js?v=<%= documentTitleJsVer %>"></script>

</body>
</html>
