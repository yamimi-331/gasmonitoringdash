<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>로그인</title>
	
<script>
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
   
</script>
</head>
<body>
	<div class="container">
    	<h2>로그인</h2>
    	<div class="inner-container">
		<form action="login" method="post" class="signup-form" onsubmit="return validateForm()">
			<!-- 아이디 입력 그룹 -->
			<div class="form-group">
			 	<label for="userId">아이디</label>
                <div class="id-check-group">
                    <input class="input-area" type="text" name="user_id" id="user_id" autocomplete="off">
                </div>
			</div>
			
			<!-- 비밀번호 입력 그룹 --> 
			<div class="form-group">
                <label for="userPw">비밀번호</label>
                <input  class="input-area" type="password" name="user_pw" id="user_pw" autocomplete="new-password">
            </div>
            
            <!-- 로그인 회원가입 버튼 그룹 -->
            <div class="form-group">
               <input class="input-submit-area" type="submit" value="로그인"/>
               <input class="input-submit-area" type="button" onclick="location.href='/signup'" value="회원가입"/>
               <input class="input-submit-area" type="button" onclick="location.href='/'" value="메인페이지"/>
            </div>
		</form>
		</div>
	</div>
		
	<!-- 여긴 높이 보정용 푸터 입니다. -->
	<footer></footer>
	<c:if test="${not empty errorMessage}">
   	 	<script>
        	alert('${errorMessage}');
    	</script>
	</c:if>
	
</body>
</html>