<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
<script type="text/javascript" src="../../resources/js/signup.js"></script>
</head>
<body>
	<h2>회원가입</h2>
	<div>
		<form action="signup" method="post" onsubmit="return validateForm()">
			<div>
				<label for="user_id">아이디</label>
				<input type="text" name="user_id" id="user_id"autocomplete="off">
				<input class="input-btn-area" type="button" onclick="checkDuplicateId()" value="중복확인">
			</div>
			<div>
				<label for="user_pw">비밀번호</label>
				<input type="password" name="user_pw" id="user_pw" autocomplete="new-password" oninput="checkPwd()">
			</div>
			<div>
				<label for="user_pw_ckCk">비밀번호 확인</label>
				<input type="password" name="user_pw_ck" id="user_pw_ck" autocomplete="new-password" oninput="checkPwd()">
				<div class="invalidFeedback"></div>
			</div>
			<div>
				<label for="user_nm">이름</label>
				<input type="text" name="user_nm" id="user_nm" autocomplete="off">
			</div>
			<div>
				<label for="local_cd">지역</label>
					<select id="local_cd" name="local_cd" required>
						<option value="">-- 지역 선택 --</option>
						<optgroup label="local">
							<c:forEach var="local" items="${localList}">
								<option value="${local.local_cd.toString()}">${local.local_nm}</option>
							</c:forEach>
						</optgroup>
					</select>
			</div>
			<div>
				<label for="user_addr">상세주소</label> 
				<input type="text" name="user_addr" id="user_addr" autocomplete="off">
			</div>
			<div>
				<input type="radio" name="user_type" value="common" id="common" checked><label for="common">일반 회원</label>
				<input type="radio" name="user_type" value="preManager" id="preManager"><label for="preManager">매니저</label>
				<input type="radio" name="user_type" value="preAdmin" id="preAdmin"><label for="preAdmin">관리자</label>
			</div>
			<input type="submit" value="가입하기">
			<input type="button" onclick="location.href='/'" value="메인페이지"/>
		</form>
	</div>
</body>
</html>