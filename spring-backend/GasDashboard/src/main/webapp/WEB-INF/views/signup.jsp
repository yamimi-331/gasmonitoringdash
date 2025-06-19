<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<script>
let isIdChecked = false; // 아이디 중복 확인 완료 여부
let isPwdValid = false;  // 비밀번호 확인 완료 여부
let isEmailVerified = false; // 이메일 인증 완료 여부

function validateForm() {
    const userIdInput = document.querySelector('input[name="userId"]');
    const userPwInput = document.querySelector('input[name="userPw"]');
    const userNmInput = document.querySelector('input[name="userNm"]');
        
    const userId = userIdInput.value.trim();
    const userPw = userPwInput.value.trim();
    const userNm = userNmInput.value.trim();
    
    if (userId === "" || userId === null) {
        alert("아이디를 입력해주세요.");
        userIdInput.focus();
        return false; // Prevent form submission
    }
    if (!isIdChecked) {
        alert("아이디 중복 확인을 해주세요.");
        userIdInput.focus();
        return false;
    }
    if (userPw === "" || userPw === null) {
        alert("비밀번호를 입력해주세요.");
        userPwInput.focus();
        return false;
    }
    if (!isPwdValid) {
        alert("비밀번호 확인을 완료해주세요.");
        document.querySelector("#userPwCk").focus();
        return false;
    }
    if (userNm === "" || userNm === null) {
        alert("이름을 입력해주세요.");
        userNmInput.focus();
        return false;
    }
    return true;
}

// 아이디 중복 확인
function checkDuplicateId() {
        const userId = document.querySelector('input[name="userId"]').value;
        if (!userId) {
            alert("아이디를 입력하세요.");
            return;
        }

        fetch("/check-id?userId=" + encodeURIComponent(userId))
            .then(res => res.text())
            .then(result => {
                if (result === "duplicate") {
                    alert("이미 사용 중인 아이디입니다.");
                    isIdChecked = false;
                } else {
                    alert("사용 가능한 아이디입니다!");
                    isIdChecked = true;
                }
            })
            .catch(err => {
                console.error("중복 확인 에러:", err);
                isIdChecked = false;
            });
}

// 비밀번호 확인 검사
function checkPwd() {
    const pw = document.querySelector("#userPw").value;
    const pw_ck = document.querySelector("#userPwCk").value;

    const pw_ckInput = document.querySelector("#userPwCk");
    const feedback = document.querySelector(".invalidFeedback");

    pw_ckInput.classList.remove("is-valid", "is-invalid");
    feedback.textContent = "";
    feedback.style.color = "";

    if (pw === "" || pw_ck === "" || pw !== pw_ck) {
        pw_ckInput.classList.add("is-invalid");
        feedback.textContent = "비밀번호가 일치하지 않습니다.";
        feedback.style.color = "red";
        isPwdValid = false;
    } else {
        pw_ckInput.classList.add("is-valid");
        isPwdValid = true;
    }
}

// 이벤트 등록 (DOM 로드 이후 실행)
document.addEventListener("DOMContentLoaded", function () {
    const pwCkInput = document.querySelector("#userPwCk");
    const form = document.querySelector("#signupForm");

    if (pwCkInput) {
        pwCkInput.addEventListener("input", checkPwd);
    }

    if (form) {
        form.addEventListener("submit", function (event) {
            if (!validateForm()) {
                event.preventDefault();
            }
        });
    }
});
</script>
<body>
	<h2>회원가입</h2>
	<div>
		<form action="signup" method="post" onsubmit="return validateForm()">
			<div>
				<label for="userId">아이디</label>
				<input type="text" name="userId" id="userId"autocomplete="off">
				<input class="input-btn-area" type="button" onclick="checkDuplicateId()" value="중복확인">
			</div>
			<div>
				<label for="userPw">비밀번호</label>
				<input type="password" name="userPw" id="userPw" autocomplete="new-password" oninput="checkPwd()">
			</div>
			<div>
				<label for="userPwCk">비밀번호 확인</label>
				<input type="password" name="userPwCk" id="userPwCk" autocomplete="new-password" oninput="checkPwd()">
				<div class="invalidFeedback"></div>
			</div>
			<div>
				<label for="userNm">이름</label>
				<input type="text" name="userNm" id="userNm" autocomplete="off">
			</div>
			<div>
				<label for="userLocal">지역</label> 
				<input type="text" name="userLocal" id="userLocal" autocomplete="off">
			</div>
			<div>
				<label for="userAddr">상세주소</label> 
				<input type="text" name="userAddr" id="userAddr" autocomplete="off">
			</div>
			<input type="submit" value="가입하기">
		</form>
	</div>
</body>
</html>