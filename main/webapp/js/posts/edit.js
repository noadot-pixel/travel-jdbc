const editQuill = initQuillEditor({
    containerId: "writeBodyEditor",
    hiddenInputId: "writeBody",
    initialHtml: window.editInitialHtml,
    uploadUrl: window.contextPath + "/post/uploadImage",
    loginUrl: window.contextPath + "/member/login",
    placeholderKey: "write.editorPlaceholder",
    placeholderFallback: "여행 이야기를 자유롭게 남겨주세요"
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

        alert(window.t("write.submitValidationAlert", "제목, 본문, 여행지 구분, 지역, 여행 성향을 모두 입력/선택해 주세요."));
    }

});
