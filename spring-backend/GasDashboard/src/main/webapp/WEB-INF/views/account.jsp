<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
<table>
	<colgroup>
		<col width="25%">
		<col width="25%">
		<col width="25%">
		<col width="25%">
	</colgroup>
	<tr>
		<th>아이디</th>
		<th>이름</th>
		<th>현재 등급</th>
		<th>승인 버튼</th>
	</tr>
	<c:choose>
		<c:when test="${not empty manageUser}">
			<c:forEach var="item" items="${manageUser}">
				<tr>
					<td>${item.user_id}</td>
					<td>${item.user_nm}</td>
					<td>${item.user_type}</td>
					<td><button>승인</button></td>
				</tr>
			</c:forEach>
		</c:when>
		<c:otherwise>
			<tr>
				<td colspan="4">${ accountManageMsg }</td>
			</tr>
		</c:otherwise>
	</c:choose>
</table>
</body>
</html>