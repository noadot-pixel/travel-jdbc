/*
 * options:
 *   containerId   - 에디터를 넣을 <div> id
 *   hiddenInputId - 제출할 "본문" hidden input id (폼 제출 시 에디터 HTML로 채워짐)
 *   initialHtml   - 기존 글 수정일 때 미리 채울 HTML (없으면 빈 에디터로 시작)
 *   uploadUrl     - 본문 이미지 업로드 API 주소
 *   loginUrl      - 업로드 도중 로그인이 풀려있으면 보낼 주소
 *   placeholderKey      - 빈 에디터에 보여줄 안내 문구의 i18n 키 (window.t로 풀어 씀)
 *   placeholderFallback - 그 키가 사전에 없을 때(또는 사전이 아직 안 로딩됐을 때) 쓸 한국어 원문
 *
 * 돌려주는 quill 인스턴스로 quill.getText()/quill.root 등을 직접 써서
 * 페이지마다 필요한 제출 전 검사(예: 본문이 비었는지)를 할 수 있다.
 */
//파일 하나를 업로드하고, 성공하면 에디터 커서 위치에 <img>로 끼워 넣는다.
//클릭으로 올리든, 붙여넣기(Ctrl+V)로 넣든, 끌어다 놓든 전부 이 한 경로로만 들어오게 해야 한다 -
//Quill 기본 동작(클립보드/드롭 이미지를 base64로 통째로 본문에 박아버림)을 그대로 두면
//사진 한두 장만으로도 본문이 수 MB짜리 글자 덩어리가 되어, 폼 전송 자체가 조용히 실패한다
//(서버 쪽 요청 크기 제한에 걸려도 에러 메시지 하나 없이 그냥 안 올라간다).
function uploadAndInsertImage(quill, file, options) {

    if (!file || file.type.indexOf("image") !== 0) {
        return;
    }

    if (file.size >= 10 * 1024 * 1024) {
        quill.setUploadStatus("error", window.t("write.imageTooLargeAlert", "10MB 미만의 이미지만 올릴 수 있습니다."));
        return;
    }

    const formData = new FormData();
    formData.append("image", file);

    quill.pendingUploads++;
    quill.setUploadStatus("loading", window.t("editor.uploading", "사진을 업로드하고 있어요…"));

    return fetch(options.uploadUrl, { method: "POST", body: formData })
        .then(function (res) { return res.json(); })
        .then(function (data) {

            if (data.result === "login") {
                location.href = options.loginUrl;
                return;
            }

            if (data.result !== "ok") {
                quill.setUploadStatus("error", window.t("write.imageUploadFailedAlert", "이미지 업로드에 실패했습니다."));
                return;
            }

            const range = quill.getSelection(true) || { index: quill.getLength() };
            quill.insertEmbed(range.index, "image", data.url, "user");
            quill.setSelection(range.index + 1);
            quill.setUploadStatus("success", window.t("editor.uploaded", "사진을 추가했어요."));

        })
        .catch(function () {
            quill.setUploadStatus("error", window.t("write.imageUploadFailedAlert", "이미지 업로드에 실패했습니다."));
        })
        .finally(function () {
            quill.pendingUploads--;
            if (quill.pendingUploads > 0) {
                quill.setUploadStatus("loading", window.t("editor.uploading", "사진을 업로드하고 있어요…"));
            }
        });
}

function initQuillEditor(options) {

    //placeholder는 Quill 생성 시점에 한 번 고정되는 옵션이 아니라, 에디터 root의
    //data-placeholder 속성(CSS가 ::before로 보여줌)이라 언제든 다시 써넣을 수 있다.
    //헤더의 i18n 사전이 비동기로 로딩되는 동안엔 한국어 fallback이 잠깐 보일 수 있지만,
    //사전이 로딩되는 즉시(i18n:applied) 그리고 언어를 바꿀 때마다 아래서 다시 맞춰 넣는다.
    function resolvePlaceholder() {
        return options.placeholderKey
            ? window.t(options.placeholderKey, options.placeholderFallback || "")
            : (options.placeholderFallback || "");
    }

    //Quill 2.x의 툴바(.ql-toolbar)는 에디터(.ql-container)의 자식이 아니라 형제로
    //생성된다. 둘을 하나로 묶어 테두리/그림자를 입히려고 감싸는 래퍼가 필요하다.
    const container = document.getElementById(options.containerId);
    const shell = document.createElement("div");
    shell.className = "editor-shell";
    container.before(shell);
    shell.append(container);

    const quill = new Quill("#" + options.containerId, {
        theme: "snow",
        placeholder: resolvePlaceholder(),
        modules: {
            toolbar: {
                container: [
                    ["bold", "italic", "underline"],
                    [{ header: [1, 2, 3, false] }],
                    [{ list: "ordered" }, { list: "bullet" }],
                    ["link", "image"],
                    ["clean"]
                ],
                handlers: {
                    //툴바의 이미지 버튼 - 파일 선택 창을 띄운다.
                    image: function () {

                        const input = document.createElement("input");
                        input.setAttribute("type", "file");
                        input.setAttribute("accept", "image/*");
                        input.click();

                        input.addEventListener("change", function () {
                            uploadAndInsertImage(quill, input.files[0], options);
                        });

                    }
                }
            }
        }
    });

    if (options.initialHtml) {
        quill.clipboard.dangerouslyPasteHTML(options.initialHtml);
        quill.history.clear();
    }

    //툴바 맨 앞에 실행취소/다시실행 버튼을 직접 추가한다 (Quill 기본 툴바 구성에는 없음).
    const toolbar = quill.getModule("toolbar").container;
    const historyGroup = document.createElement("span");
    historyGroup.className = "ql-formats";
    [["undo", "↶"], ["redo", "↷"]].forEach(function (item) {
        const button = document.createElement("button");
        button.type = "button";
        button.dataset.history = item[0];
        button.textContent = item[1];
        button.addEventListener("click", function () { quill.history[item[0]](); });
        historyGroup.append(button);
    });
    toolbar.prepend(historyGroup);

    //업로드 진행 상태 + 글자수/사진수를 보여주는 상태표시줄을 에디터 아래에 붙인다.
    const statusbar = document.createElement("div");
    statusbar.className = "editor-statusbar";
    const status = document.createElement("span");
    status.className = "editor-upload-status";
    status.setAttribute("role", "status");
    const counter = document.createElement("span");
    counter.className = "editor-count";
    statusbar.append(status, counter);
    shell.append(statusbar);

    quill.pendingUploads = 0;
    quill.setUploadStatus = function (state, message) {
        status.dataset.state = state;
        status.textContent = message;
    };

    function updateCount() {
        const length = Array.from(quill.getText().replace(/\n$/, "")).length;
        counter.textContent = length.toLocaleString() + window.t("editor.charUnit", "자") + " · " +
            window.t("editor.photo", "사진") + " " + quill.root.querySelectorAll("img").length;
    }
    quill.on("text-change", updateCount);

    //툴바 버튼들의 title/aria-label, heading 드롭다운 항목, 상태표시줄 안내문구를
    //언어가 바뀔 때마다(i18n:applied) 다시 맞춰 넣는다.
    function translateEditor() {

        quill.root.setAttribute("data-placeholder", resolvePlaceholder());
        quill.root.setAttribute("aria-label", window.t("write.bodyLabel", "본문"));

        const labels = [
            [".ql-bold", "bold", "굵게 (Ctrl+B)"], [".ql-italic", "italic", "기울임 (Ctrl+I)"],
            [".ql-underline", "underline", "밑줄 (Ctrl+U)"], [".ql-list[value=ordered]", "ordered", "번호 목록"],
            [".ql-list[value=bullet]", "bullet", "글머리 기호"], [".ql-link", "link", "링크 삽입"],
            [".ql-image", "image", "사진 추가"], [".ql-clean", "clean", "서식 지우기"],
            ["[data-history=undo]", "undo", "실행 취소"], ["[data-history=redo]", "redo", "다시 실행"]
        ];
        labels.forEach(function (item) {
            const button = toolbar.querySelector(item[0]);
            button.title = window.t("editor." + item[1], item[2]);
            button.setAttribute("aria-label", button.title);
        });

        const picker = toolbar.querySelector(".ql-header.ql-picker");
        picker.querySelectorAll(".ql-picker-item, .ql-picker-label").forEach(function (item) {
            const level = item.dataset.value;
            const label = level ? window.t("editor.heading" + level, "제목 " + level) : window.t("editor.paragraph", "본문");
            item.dataset.label = label;
            item.setAttribute("aria-label", label);
        });

        if (!status.dataset.state) {
            status.textContent = window.t("editor.imageHint", "사진 붙여넣기·끌어놓기 가능 · 10MB 미만");
        }

        updateCount();
    }
    toolbar.querySelector("select.ql-header").addEventListener("change", translateEditor);
    quill.on("selection-change", translateEditor);

    //<label for="writeBodyEditor">가 (원래 div였던) 진짜 편집 영역을 가리키도록 id를 옮긴다.
    quill.root.id = options.containerId + "-input";
    quill.root.setAttribute("role", "textbox");
    quill.root.setAttribute("aria-multiline", "true");
    const label = document.querySelector('label[for="' + options.containerId + '"]');
    if (label) {
        label.htmlFor = quill.root.id;
    }

    translateEditor();
    $(document).on("i18n:applied", translateEditor);

    //Quill은 placeholder 표시 여부(ql-blank 클래스)를 text-change 이벤트에서만 갱신하는데,
    //IME 조합 중(한국어/일본어/중국어 등)엔 조합 후보 창이 깨지지 않도록 text-change를
    //일부러 compositionend까지 미룬다. 그래서 일본어 등을 입력하는 동안 아직 글자가
    //화면에 찍히고 있는데도 placeholder가 그 위에 그대로 겹쳐 보이다가, 변환을 확정해야
    //(enter 등으로 compositionend가 발생해야) 사라진다. 조합이 시작되는 즉시 직접
    //지워주고, 조합이 끝나면 Quill 본래의 text-change 처리가 다시 정확한 상태로 맞춘다
    //(변환을 취소해서 결과적으로 빈 칸이 됐을 때도 포함해서).
    quill.root.addEventListener("compositionstart", function () {
        quill.root.classList.remove("ql-blank");
    });

    //붙여넣기(클립보드 이미지)도 업로드 경로로 보낸다. capture 단계에서 먼저 가로채고
    //stopImmediatePropagation으로 Quill 자체의 base64 붙여넣기 처리를 막는다.
    quill.root.addEventListener("paste", function (event) {

        const items = (event.clipboardData || window.clipboardData).items;

        if (!items) {
            return;
        }

        for (let i = 0; i < items.length; i++) {

            if (items[i].type.indexOf("image") === 0) {

                event.preventDefault();
                event.stopImmediatePropagation();

                uploadAndInsertImage(quill, items[i].getAsFile(), options);

                return;
            }

        }

    }, true);

    //끌어다 놓기(드래그 앤 드롭)도 같은 이유로 가로챈다.
    quill.root.addEventListener("dragover", function (event) {
        event.preventDefault();
    }, true);

    quill.root.addEventListener("drop", function (event) {

        const files = event.dataTransfer && event.dataTransfer.files;

        if (!files || files.length === 0) {
            return;
        }

        for (let i = 0; i < files.length; i++) {

            if (files[i].type.indexOf("image") === 0) {

                event.preventDefault();
                event.stopImmediatePropagation();

                uploadAndInsertImage(quill, files[i], options);

                return;
            }

        }

    }, true);

    const hiddenInput = document.getElementById(options.hiddenInputId);
    const form = hiddenInput.closest("form");

    //제출 순간의 에디터 내용을 hidden input에 채운다. 이 리스너를 가장 먼저 등록해야
    //(즉 페이지의 다른 제출 전 검사 스크립트보다 initQuillEditor를 먼저 호출해야)
    //검사 스크립트가 "방금 채워진" 값을 보고 판단할 수 있다.
    //업로드가 아직 끝나지 않았으면 제출 자체를 막는다 - 안 그러면 막 올리던 사진이
    //빠진 채로(또는 커서 위치가 꼬인 채로) 본문이 그대로 저장돼버릴 수 있다.
    form.addEventListener("submit", function (event) {

        if (quill.pendingUploads > 0) {
            event.preventDefault();
            event.stopImmediatePropagation();
            quill.setUploadStatus("loading", window.t("editor.waitUpload", "사진 업로드가 끝나면 다시 등록해 주세요."));
            return;
        }

        hiddenInput.value = quill.getSemanticHTML();
    });

    return quill;
}
