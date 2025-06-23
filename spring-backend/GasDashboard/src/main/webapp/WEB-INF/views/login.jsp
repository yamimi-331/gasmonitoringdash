<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>로그인</title>
<script type="text/javascript" src="../../resources/js/login.js"></script>
<link href="../../resources/css/common.css?after" rel="stylesheet" type="text/css">
<link href="../../resources/css/user.css?after" rel="stylesheet" type="text/css">
</head>
<body>
	<header></header>
	<main>
		<div class="form-container">
			<div class="form-title">
				<h2 class="text-center">로그인</h2>
			</div>
			<form action="login" method="post" class="user-form" onsubmit="return validateForm()">
				<!-- 아이디 입력 그룹 -->
				<div class="form-group">
					<label for="userId">아이디</label>
					<input class="input-area" type="text" name="user_id" id="user_id" autocomplete="off">
				</div>
				
				<!-- 비밀번호 입력 그룹 --> 
				<div class="form-group">
					<label for="userPw">비밀번호</label>
					<input class="input-area" type="password" name="user_pw" id="user_pw" autocomplete="off">
				</div>
	            
	            <!-- 로그인 회원가입 버튼 그룹 -->
				<div class="button-group">
					<input class="submit-area" type="submit" value="로그인"/>
					<input class="submit-area" type="button" onclick="location.href='/signup'" value="회원가입"/>
					<a class="go-main" href="/">메인페이지</a>
				</div>
			</form>
		</div>
	</main>
		
	<footer></footer>
	
	<c:if test="${not empty errorMessage}">
   	 	<script>
        	alert('${errorMessage}');
    	</script>
	</c:if>
	
</body>
</html>