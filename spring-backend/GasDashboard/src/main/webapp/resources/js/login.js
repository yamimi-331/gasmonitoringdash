/**
 * 
 */

// 로그인 밸리데이션
   function validateForm() {
    	const userIdInput = document.querySelector('input[name="user_id"]');
		const userPwInput = document.querySelector('input[name="user_pw"]');
			
		const userId = userIdInput.value.trim();
		const userPw = userPwInput.value.trim();
        
		if (userId === "" || userId === null) {
            alert("아이디를 입력해주세요.");
            userIdInput.focus();
            return false; // Prevent form submission
        }
     
        if (userPw === "" || userPw === null) {
            alert("비밀번호를 입력해주세요.");
            userPwInput.focus();
            return false;
        }
        return true;
    }