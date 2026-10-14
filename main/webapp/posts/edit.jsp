<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

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

    //PostModifyFormCommand(GET) 또는 실패 후 재진입한 PostModifyCommand(POST)가 넣어준 글.
    PostDTO post = (PostDTO) request.getAttribute("post");

    if (post == null) {
        response.sendRedirect(contextPath + "/post/list");
        return;
    }

    String msg = (String) request.getAttribute("msg");

    //실패해서 다시 돌아온 경우에는 방금 입력했던 값을 유지하고, 처음 들어온 경우에는 기존 글 값을 보여준다.
    String titleValue = request.getParameter("writeTitle") != null ? request.getParameter("writeTitle") : post.getTitle();
    String bodyValue = request.getParameter("writeBody") != null ? request.getParameter("writeBody") : post.getContent();
    String countryValue = request.getParameter("country") != null ? request.getParameter("country") : post.getCountry();
    String regionValue = request.getParameter("region") != null ? request.getParameter("region") : post.getRegion();
    String styleValue = request.getParameter("style") != null ? request.getParameter("style") : post.getStyle();
%>

<!DOCTYPE html>
<html lang="ko">

<head>
    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>게시글 수정 - 여행만들기</title>

    <%@ include file="/common/css-links.jspf" %>
</head>

<body>

<% String activeNav = "posts"; %>
<%@ include file="/common/header.jsp" %>

<main>

    <section class="page-heading">

        <p class="breadcrumb">
            <a href="<%= contextPath %>/main">홈</a>
            〉 <a href="<%= contextPath %>/post/list">게시글 목록</a>
            〉 게시글 수정
        </p>

        <h1>게시글 수정</h1>

        <p class="page-description">
            여행지 구분과 여행 성향을 각각 하나씩 선택하고 내용을 수정하세요.
        </p>

    </section>

    <% if (msg != null) { %>
    <p class="field-error"><%= EscapeUtil.html(msg) %></p>
    <% } %>

    <section class="write-section">

        <form id="editForm"
              method="post"
              action="<%= contextPath %>/post/modify">

            <input type="hidden" name="bno" value="<%= post.getBno() %>">

            <div class="write-field">

                <label for="writeTitle">
                    제목
                </label>

                <input type="text"
                       id="writeTitle"
                       name="writeTitle"
                       value="<%= EscapeUtil.html(titleValue) %>"
                       placeholder="제목을 입력해 주세요">

            </div>

            <input type="hidden" id="countryInput" name="country" value="<%= countryValue %>">
            <input type="hidden" id="regionInput" name="region" value="<%= regionValue != null ? regionValue : "" %>">
            <input type="hidden" id="styleInput" name="style" value="<%= styleValue %>">

            <div class="filter-group" id="writeCountryGroup">

                <p class="filter-label">여행지 구분</p>

                <button type="button" class="filter-button <%= "KR".equals(countryValue) ? "active" : "" %>" data-country="KR">국내여행</button>
                <button type="button" class="filter-button <%= "JP".equals(countryValue) ? "active" : "" %>" data-country="JP">일본여행</button>
                <button type="button" class="filter-button <%= "ETC".equals(countryValue) ? "active" : "" %>" data-country="ETC">해외여행</button>

            </div>

            <div class="filter-group" id="writeKoreaRegionGroup" <%= "KR".equals(countryValue) ? "" : "hidden" %>>

                <p class="filter-label">국내 지역</p>

                <button type="button" class="filter-button <%= "KR_CAPITAL".equals(regionValue) ? "active" : "" %>" data-region="KR_CAPITAL">서울·경기·인천</button>
                <button type="button" class="filter-button <%= "KR_GANGWON".equals(regionValue) ? "active" : "" %>" data-region="KR_GANGWON">강원도</button>
                <button type="button" class="filter-button <%= "KR_CHUNGCHEONG".equals(regionValue) ? "active" : "" %>" data-region="KR_CHUNGCHEONG">충청도</button>
                <button type="button" class="filter-button <%= "KR_JEOLLA".equals(regionValue) ? "active" : "" %>" data-region="KR_JEOLLA">전라도</button>
                <button type="button" class="filter-button <%= "KR_GYEONGSANG".equals(regionValue) ? "active" : "" %>" data-region="KR_GYEONGSANG">경상도</button>
                <button type="button" class="filter-button <%= "KR_JEJU".equals(regionValue) ? "active" : "" %>" data-region="KR_JEJU">제주도</button>

            </div>

            <div class="filter-group" id="writeJapanRegionGroup" <%= "JP".equals(countryValue) ? "" : "hidden" %>>

                <p class="filter-label">일본 지역</p>

                <button type="button" class="filter-button <%= "JP_HOKKAIDO".equals(regionValue) ? "active" : "" %>" data-region="JP_HOKKAIDO">홋카이도 지방</button>
                <button type="button" class="filter-button <%= "JP_TOHOKU".equals(regionValue) ? "active" : "" %>" data-region="JP_TOHOKU">도호쿠 지방</button>
                <button type="button" class="filter-button <%= "JP_KANTO".equals(regionValue) ? "active" : "" %>" data-region="JP_KANTO">간토 지방</button>
                <button type="button" class="filter-button <%= "JP_CHUBU".equals(regionValue) ? "active" : "" %>" data-region="JP_CHUBU">주부 지방</button>
                <button type="button" class="filter-button <%= "JP_KANSAI".equals(regionValue) ? "active" : "" %>" data-region="JP_KANSAI">긴키·간사이 지방</button>
                <button type="button" class="filter-button <%= "JP_CHUGOKU".equals(regionValue) ? "active" : "" %>" data-region="JP_CHUGOKU">주고쿠 지방</button>
                <button type="button" class="filter-button <%= "JP_SHIKOKU".equals(regionValue) ? "active" : "" %>" data-region="JP_SHIKOKU">시코쿠 지방</button>
                <button type="button" class="filter-button <%= "JP_KYUSHU_OKINAWA".equals(regionValue) ? "active" : "" %>" data-region="JP_KYUSHU_OKINAWA">규슈·오키나와 지방</button>

            </div>

            <div class="filter-group" id="writeStyleGroup">

                <p class="filter-label">여행 성향</p>

                <button type="button" class="filter-button <%= "healing".equals(styleValue) ? "active" : "" %>" data-style="healing">힐링</button>
                <button type="button" class="filter-button <%= "food".equals(styleValue) ? "active" : "" %>" data-style="food">맛집</button>
                <button type="button" class="filter-button <%= "activity".equals(styleValue) ? "active" : "" %>" data-style="activity">액티비티</button>
                <button type="button" class="filter-button <%= "shopping".equals(styleValue) ? "active" : "" %>" data-style="shopping">쇼핑</button>

            </div>

            <div class="write-field">

                <label for="writeBodyEditor">
                    본문
                </label>

                <div id="writeBodyEditor" class="quill-editor-container"></div>
                <input type="hidden" id="writeBody" name="writeBody">

                <p class="write-field-note">
                    이미지 버튼으로 본문 중간에 사진을 넣을 수 있어요(5MB 미만). 본문의 첫 사진이
                    목록 카드 썸네일로 쓰이고, 사진이 없으면 여행지 구분에 맞는 기본 이미지가 쓰입니다.
                </p>

            </div>

            <button type="submit" class="auth-submit">
                수정하기
            </button>

        </form>

    </section>

</main>

<%@ include file="/common/footer.jsp" %>
<%@ include file="/common/quill-assets.jspf" %>

<script>
    const editQuill = initQuillEditor({
        containerId: "writeBodyEditor",
        hiddenInputId: "writeBody",
        initialHtml: "<%= EscapeUtil.json(bodyValue) %>",
        uploadUrl: "<%= contextPath %>/post/uploadImage",
        loginUrl: "<%= contextPath %>/member/login",
        placeholder: "여행 이야기를 자유롭게 남겨주세요"
    });

    function bindFilterGroup(groupId, hiddenInputId, datasetKey) {

        const group = document.getElementById(groupId);
        const hiddenInput = document.getElementById(hiddenInputId);
        const buttons = group.querySelectorAll(".filter-button");

        buttons.forEach(function (button) {

            button.addEventListener("click", function () {

                buttons.forEach(function (other) {
                    other.classList.remove("active");
                });

                button.classList.add("active");

                hiddenInput.value = button.dataset[datasetKey];

            });

        });

    }

    bindFilterGroup("writeCountryGroup", "countryInput", "country");
    bindFilterGroup("writeKoreaRegionGroup", "regionInput", "region");
    bindFilterGroup("writeJapanRegionGroup", "regionInput", "region");
    bindFilterGroup("writeStyleGroup", "styleInput", "style");

    /*
     * 여행지 구분을 바꾸면 지역 선택지를 보여주거나 숨긴다. 처음 로딩 때는 기존 글의
     * 국가에 맞는 그룹이 이미 서버에서 보여지는 상태로 내려오므로(hidden 속성), 여기서는
     * "사용자가 버튼을 눌러 바꿨을 때"만 처리하면 된다.
     */

    const regionInput = document.getElementById("regionInput");
    const koreaRegionGroup = document.getElementById("writeKoreaRegionGroup");
    const japanRegionGroup = document.getElementById("writeJapanRegionGroup");
    let previousCountry = document.getElementById("countryInput").value;

    document.querySelectorAll("#writeCountryGroup .filter-button").forEach(function (button) {

        button.addEventListener("click", function () {

            const selectedCountry = button.dataset.country;

            if (previousCountry !== selectedCountry) {
                regionInput.value = "";
                document.querySelectorAll("#writeKoreaRegionGroup .filter-button, #writeJapanRegionGroup .filter-button")
                    .forEach(function (regionButton) {
                        regionButton.classList.remove("active");
                    });
            }

            koreaRegionGroup.hidden = selectedCountry !== "KR";
            japanRegionGroup.hidden = selectedCountry !== "JP";

            previousCountry = selectedCountry;

        });

    });

    document.getElementById("editForm").addEventListener("submit", function (event) {

        const selectedCountry = document.getElementById("countryInput").value;
        const regionRequired = selectedCountry === "KR" || selectedCountry === "JP";
        const bodyIsEmpty = editQuill.getText().trim() === "" && editQuill.root.querySelectorAll("img").length === 0;

        if (document.getElementById("writeTitle").value.trim() === ""
            || bodyIsEmpty
            || selectedCountry === ""
            || document.getElementById("styleInput").value === ""
            || (regionRequired && regionInput.value === "")) {

            event.preventDefault();

            alert("제목, 본문, 여행지 구분, 지역, 여행 성향을 모두 입력/선택해 주세요.");
        }

    });
</script>

</body>
</html>
