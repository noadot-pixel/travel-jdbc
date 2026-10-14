<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%@ page import="model.MemberDTO" %>
<%@ page import="util.EscapeUtil" %>

<%
    String contextPath = request.getContextPath();

    //컨트롤러(PostController)가 이미 로그인을 확인하지만, 이 화면으로 직접 들어오는
    //경우까지 막도록 한 번 더 확인한다 (BlogProject의 write.jsp도 같은 방식).
    MemberDTO loginMember = (MemberDTO) session.getAttribute("loginMember");

    if (loginMember == null) {
        response.sendRedirect(contextPath + "/member/login");
        return;
    }

    String msg = (String) request.getAttribute("msg");   // 등록 실패 시 PostWriteCommand가 넣어준 메시지
%>

<!DOCTYPE html>
<html lang="ko">

<head>
    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>여행 이야기 작성 - 여행만들기</title>

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
            〉 글쓰기
        </p>

        <h1>여행 이야기 작성</h1>

        <p class="page-description">
            여행지 구분과 여행 성향을 각각 하나씩 선택하고 이야기를 남겨보세요.
        </p>

    </section>

    <% if (msg != null) { %>
    <p class="field-error"><%= EscapeUtil.html(msg) %></p>
    <% } %>

    <section class="write-section">

        <!-- 사진은 에디터가 /post/uploadImage로 별도 업로드하므로, 이 폼 자체는 파일을 보내지 않는다 -->
        <form id="writeForm"
              method="post"
              action="<%= contextPath %>/post/write">

            <div class="write-field">

                <label for="writeTitle">
                    제목
                </label>

                <input type="text"
                       id="writeTitle"
                       name="writeTitle"
                       value="<%= EscapeUtil.html(request.getParameter("writeTitle")) %>"
                       placeholder="제목을 입력해 주세요">

            </div>

            <!-- 선택한 값은 JS가 이 hidden input에 채워서 서버로 보낸다 -->
            <input type="hidden" id="countryInput" name="country" value="">
            <input type="hidden" id="regionInput" name="region" value="">
            <input type="hidden" id="styleInput" name="style" value="">

            <div class="filter-group" id="writeCountryGroup">

                <p class="filter-label">여행지 구분</p>

                <button type="button" class="filter-button" data-country="KR">국내여행</button>
                <button type="button" class="filter-button" data-country="JP">일본여행</button>
                <button type="button" class="filter-button" data-country="ETC">해외여행</button>

            </div>

            <!-- 국내여행을 선택했을 때만 보여준다 -->
            <div class="filter-group" id="writeKoreaRegionGroup" hidden>

                <p class="filter-label">국내 지역</p>

                <button type="button" class="filter-button" data-region="KR_CAPITAL">서울·경기·인천</button>
                <button type="button" class="filter-button" data-region="KR_GANGWON">강원도</button>
                <button type="button" class="filter-button" data-region="KR_CHUNGCHEONG">충청도</button>
                <button type="button" class="filter-button" data-region="KR_JEOLLA">전라도</button>
                <button type="button" class="filter-button" data-region="KR_GYEONGSANG">경상도</button>
                <button type="button" class="filter-button" data-region="KR_JEJU">제주도</button>

            </div>

            <!-- 일본여행을 선택했을 때만 보여준다 -->
            <div class="filter-group" id="writeJapanRegionGroup" hidden>

                <p class="filter-label">일본 지역</p>

                <button type="button" class="filter-button" data-region="JP_HOKKAIDO">홋카이도 지방</button>
                <button type="button" class="filter-button" data-region="JP_TOHOKU">도호쿠 지방</button>
                <button type="button" class="filter-button" data-region="JP_KANTO">간토 지방</button>
                <button type="button" class="filter-button" data-region="JP_CHUBU">주부 지방</button>
                <button type="button" class="filter-button" data-region="JP_KANSAI">긴키·간사이 지방</button>
                <button type="button" class="filter-button" data-region="JP_CHUGOKU">주고쿠 지방</button>
                <button type="button" class="filter-button" data-region="JP_SHIKOKU">시코쿠 지방</button>
                <button type="button" class="filter-button" data-region="JP_KYUSHU_OKINAWA">규슈·오키나와 지방</button>

            </div>

            <div class="filter-group" id="writeStyleGroup">

                <p class="filter-label">여행 성향</p>

                <button type="button" class="filter-button" data-style="healing">힐링</button>
                <button type="button" class="filter-button" data-style="food">맛집</button>
                <button type="button" class="filter-button" data-style="activity">액티비티</button>
                <button type="button" class="filter-button" data-style="shopping">쇼핑</button>

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
                등록하기
            </button>

        </form>

    </section>

</main>

<%@ include file="/common/footer.jsp" %>
<%@ include file="/common/quill-assets.jspf" %>

<script>
    const writeQuill = initQuillEditor({
        containerId: "writeBodyEditor",
        hiddenInputId: "writeBody",
        uploadUrl: "<%= contextPath %>/post/uploadImage",
        loginUrl: "<%= contextPath %>/member/login",
        placeholder: "여행 이야기를 자유롭게 남겨주세요"
    });

    /*
     * 여행지 구분 / 여행 성향은 각 그룹에서 하나만 선택되도록 처리하고,
     * 고른 값을 hidden input에 채워서 폼 제출 때 서버로 보낸다.
     */

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
     * 여행지 구분(국내/일본/해외)에 따라 지역 선택지를 보여주거나 숨긴다.
     * 다른 국가로 바꾸면 이전에 골랐던 지역 선택은 초기화한다(해외로 바꿨는데
     * "제주도"가 그대로 남아있으면 안 되니까).
     */

    const regionInput = document.getElementById("regionInput");
    const koreaRegionGroup = document.getElementById("writeKoreaRegionGroup");
    const japanRegionGroup = document.getElementById("writeJapanRegionGroup");

    document.querySelectorAll("#writeCountryGroup .filter-button").forEach(function (button) {

        button.addEventListener("click", function () {

            const selectedCountry = button.dataset.country;

            regionInput.value = "";
            document.querySelectorAll("#writeKoreaRegionGroup .filter-button, #writeJapanRegionGroup .filter-button")
                .forEach(function (regionButton) {
                    regionButton.classList.remove("active");
                });

            koreaRegionGroup.hidden = selectedCountry !== "KR";
            japanRegionGroup.hidden = selectedCountry !== "JP";

        });

    });


    /*
     * 제출 전 마지막 확인 (서버도 다시 검사하지만, 사용자 편의를 위해 미리 알려준다)
     * 본문이 비었는지는 에디터의 hidden input 값이 아니라(에디터가 비어 있어도
     * "<p><br></p>"처럼 글자가 들어가므로) Quill의 getText()로 직접 확인한다.
     */

    document.getElementById("writeForm").addEventListener("submit", function (event) {

        const selectedCountry = document.getElementById("countryInput").value;
        const regionRequired = selectedCountry === "KR" || selectedCountry === "JP";
        const bodyIsEmpty = writeQuill.getText().trim() === "" && writeQuill.root.querySelectorAll("img").length === 0;

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
