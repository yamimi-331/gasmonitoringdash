/**
 * 
 */
document.addEventListener("DOMContentLoaded", function () {
    const pwField = document.getElementById("userPw");
    const pwCheckField = document.getElementById("pwCheck");
    const pwCheckMsg = document.getElementById("pwCheckMsg");
    const form = document.getElementById("profileEditForm");

    // 비밀번호 입력 감지
    pwField.addEventListener("input", checkPasswordMatch);
    pwCheckField.addEventListener("input", checkPasswordMatch);

    // 비밀번호 일치 확인
    function checkPasswordMatch() {
        const pw = pwField.value;
        const pwCheck = pwCheckField.value;

        if (pw && pwCheck && pw !== pwCheck) {
            pwCheckField.classList.add("is-invalid");
            pwCheckField.classList.remove("is-valid");
            pwCheckMsg.textContent = "비밀번호가 일치하지 않습니다.";
            pwCheckMsg.style.color = "red";
            return false;
        } else if (pw && pwCheck && pw === pwCheck) {
            pwCheckField.classList.remove("is-invalid");
            pwCheckField.classList.add("is-valid");
            pwCheckMsg.textContent = "비밀번호가 일치합니다.";
            pwCheckMsg.style.color = "green";
            return true;
        } else {
            pwCheckField.classList.remove("is-valid", "is-invalid");
            pwCheckMsg.textContent = "";
            return false;
        }
    }

    // 폼 제출 시 비밀번호 확인
    form.addEventListener("submit", function (e) {
        if (!checkPasswordMatch()) {
            alert("비밀번호가 일치하지 않습니다.");
            e.preventDefault();
        }
    });

    // 탈퇴 최종 확인 함수
    window.confirmDelete = function () {
    	if (!checkPasswordMatch()) {
            alert("비밀번호가 일치하지 않습니다.");
            e.preventDefault();
        } else {
	        if (confirm("정말로 회원을 탈퇴하시겠습니까?\n계정복구는 당사로 문의해주시기 바랍니다.")) {
	            document.getElementById('profiledeleteForm').submit();
	            return true;
	        } else {
	            return false;
	        }
	    }
    };
});
