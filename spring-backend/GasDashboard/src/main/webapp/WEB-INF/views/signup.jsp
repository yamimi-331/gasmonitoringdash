<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ page trimDirectiveWhitespaces="true" %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>DashBoard</title>
<script type="text/javascript" src="../../resources/js/signup.js"></script>
<link href="../../resources/css/common.css?after" rel="stylesheet" type="text/css">
<link href="../../resources/css/user.css?after" rel="stylesheet" type="text/css">
</head>
<body>
	<header></header>
	<main>
		<div class="form-container">
			<div class="form-title">
				<h2 class="text-center">회원가입</h2>
			</div>
			<form action="signup" method="post" class="user-form" onsubmit="return validateForm()">
				<div class="form-group">
					<label for="user_id">아이디</label>
					<div class="id-group">
						<input class="input-id" type="text" name="user_id" id="user_id" autocomplete="off">
						<input class="input-id-button" type="button" onclick="checkDuplicateId()" value="중복확인">
					</div>
				</div>
				<div class="form-group">
					<label for="user_pw">비밀번호</label>
					<input class="input-area" type="password" name="user_pw" id="user_pw" autocomplete="new-password" oninput="checkPwd()">
				</div>
				<div class="form-group">
					<label for="user_pw_ckCk">비밀번호 확인</label>
					<input class="input-area" type="password" name="user_pw_ck" id="user_pw_ck" autocomplete="new-password" oninput="checkPwd()">
					<small class="invalidFeedback"></small>
				</div>
				<div class="form-group">
					<label for="user_nm">이름</label>
					<input class="input-area" type="text" name="user_nm" id="user_nm" autocomplete="off">
				</div>
				<div class="form-group">
					<label for="local_cd">지역</label>
					<select class="select-area" id="local_cd" name="local_cd" required>
						<option value="">-- 지역 선택 --</option>
						<c:forEach var="local" items="${localList}">
							<option value="${local.local_cd.toString()}">${local.local_nm}</option>
						</c:forEach>
					</select>
				</div>
				<div class="form-group">
					<label for="user_addr">상세주소</label> 
					<input class="input-area" type="text" name="user_addr" id="user_addr" autocomplete="off">
				</div>
				<label>회원 유형</label>
				<div class="radio-group">
					<div><input type="radio" name="user_type" value="common" id="common" checked><label for="common">일반</label></div>
					<div><input type="radio" name="user_type" value="preManager" id="preManager"><label for="preManager">매니저(승인요청)</label></div>
					<div><input type="radio" name="user_type" value="preAdmin" id="preAdmin"><label for="preAdmin">관리자(승인요청)</label></div>
				</div>
				<div class="button-group">
					<input class="submit-area" type="submit" value="가입하기">
					<a class="go-main" href="/">대시보드 이동</a>
				</div>
			</form>
		</div>
	</main>
	<footer></footer>
</body>
</html>