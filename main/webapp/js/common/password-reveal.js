/*
 * 비밀번호 보기 - 아이콘에 마우스를 올리고 있거나(hover) 누르고 있는 동안만
 * 평문으로 보여주고, 떼면(또는 마우스가 벗어나면) 다시 가린다. 포인터 이벤트라
 * 마우스/터치 둘 다 같은 핸들러로 처리된다.
 *
 * 로그인/회원가입 폼이 같이 쓰는 함수라 공용 파일로 뺐다.
 */
function bindPasswordReveal(buttonId, inputId) {

    const button = document.getElementById(buttonId);
    const input = document.getElementById(inputId);

    function reveal() { input.type = "text"; }
    function hide() { input.type = "password"; }

    //mousedown 시점에 버튼이 포커스를 가져가 input의 커서 위치가 흐트러지는 걸 막는다.
    button.addEventListener("pointerdown", function (event) {
        event.preventDefault();
        reveal();
    });

    button.addEventListener("pointerenter", reveal);
    button.addEventListener("pointerup", hide);
    button.addEventListener("pointerleave", hide);
    button.addEventListener("pointercancel", hide);
}
