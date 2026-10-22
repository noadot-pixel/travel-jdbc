const writeQuill = initQuillEditor({
    containerId: "writeBodyEditor",
    hiddenInputId: "writeBody",
    uploadUrl: window.contextPath + "/post/uploadImage",
    loginUrl: window.contextPath + "/member/login",
    placeholderKey: "write.editorPlaceholder",
    placeholderFallback: "여행 이야기를 자유롭게 남겨주세요"
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
 * 같은 국가를 다시 눌렀을 때는 이미 골라둔 지역을 지우지 않는다 - 다른 국가로
 * 바꿨을 때만 "제주도"가 해외여행에 그대로 남아있는 것 같은 상황을 초기화한다.
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

        previousCountry = selectedCountry;
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

        alert(window.t("write.submitValidationAlert", "제목, 본문, 여행지 구분, 지역, 여행 성향을 모두 입력/선택해 주세요."));
    }

});
