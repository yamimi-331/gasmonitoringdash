<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>로그인</title>
</head>
<body>
	<h2>로그인</h2>

	<c:if test="${param.error == 'true'}">
		<p style="color: red;">로그인 실패: 아이디 또는 비밀번호를 확인하세요.</p>
	</c:if>
	<form action="${pageContext.request.contextPath}/login" method="post">
		<input type="text" name="username" placeholder="ID" required><br>
		<input type="Password" name="password" placeholder="PW" required>
		<button type="submit">로그인</button>
	</form>
</body>
</html>