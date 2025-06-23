<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
<script type="text/javascript" src="../../resources/js/profileEdit.js"></script>
</head>
<body>
	<div class="container mt-5">
		<h2 class="mb-4">회원정보 수정</h2>
		<!-- 회원정보 수정 폼 -->
		<form method="post" id="profileEditForm" action="/profileEdit">
			<div class="mb-3">
				<label for="userId" class="form-label">사용자 아이디</label> <input
					type="text" class="form-control" id="userId" name="user_id"
					value="${currentUserInfo.user_id}" readonly>
			</div>

			<div class="mb-3">
				<label for="userPw" class="form-label">비밀번호</label> <input
					type="password" class="form-control" id="userPw" name="user_pw"
					value="${currentUserInfo.user_pw}">
			</div>

			<div class="mb-3">
				<label for="pwCheck" class="form-label">비밀번호 확인</label> <input
					type="password" class="form-control" id="pwCheck" name="pw_check">
				 <small id="pwCheckMsg" class="form-text"></small>
			</div>

			<div class="mb-3">
				<label for="userName" class="form-label">이름</label> <input
					type="text" class="form-control" id="userName" name="user_nm"
					value="${currentUserInfo.user_nm}">
			</div>

			<div class="mb-3">
				<label for="localCd" class="form-label">지역</label> <select
					class="form-select" id="localCd" name="local_cd">
					<c:forEach var="loc" items="${localList}">
						<option value="${loc.local_cd}"
							<c:if test="${loc.local_cd == currentUserInfo.local_cd}">selected</c:if>>
							${loc.local_nm}</option>
					</c:forEach>
				</select>
			</div>

			<div class="mb-3">
				<label for="user_addr" class="form-label">상세주소</label> <input
					type="text" class="form-control" id="user_addr" name="user_addr"
					value="${currentUserInfo.user_addr}">
			</div>

			<div class="mb-3">
		    <label class="form-label">회원 유형</label>
		
		    <c:if test="${currentUserInfo.user_type == 'common'}">
		        <div class="form-check">
		            <input class="form-check-input" type="radio" name="user_type"
		                   id="typeCommon" value="common" checked>
		            <label class="form-check-label" for="typeCommon">일반</label>
		        </div>
		        <div class="form-check">
		            <input class="form-check-input" type="radio" name="user_type"
		                   id="typePreAdmin" value="preAdmin">
		            <label class="form-check-label" for="typePreAdmin">관리자(승인요청)</label>
		        </div>
		        <div class="form-check">
		            <input class="form-check-input" type="radio" name="user_type"
		                   id="typePreManager" value="preManager">
		            <label class="form-check-label" for="typePreManager">직원(승인요청)</label>
		        </div>
		    </c:if>
		
		    <c:if test="${currentUserInfo.user_type == 'preAdmin'}">
		        <div class="form-check">
		            <input class="form-check-input" type="radio" name="user_type"
		                   id="typeCommon" value="common">
		            <label class="form-check-label" for="typeCommon">일반</label>
		        </div>
		        <div class="form-check">
		            <input class="form-check-input" type="radio" name="user_type"
		                   id="typePreAdmin" value="preAdmin" checked>
		            <label class="form-check-label" for="typePreAdmin">관리자(승인요청)</label>
		        </div>
		        <div class="form-check">
		            <input class="form-check-input" type="radio" name="user_type"
		                   id="typePreManager" value="preManager">
		            <label class="form-check-label" for="typePreManager">직원(승인요청)</label>
		        </div>
		    </c:if>
		
		    <c:if test="${currentUserInfo.user_type == 'preManager'}">
		        <div class="form-check">
		            <input class="form-check-input" type="radio" name="user_type"
		                   id="typeCommon" value="common">
		            <label class="form-check-label" for="typeCommon">일반</label>
		        </div>
		        <div class="form-check">
		            <input class="form-check-input" type="radio" name="user_type"
		                   id="typePreAdmin" value="preAdmin">
		            <label class="form-check-label" for="typePreAdmin">관리자(승인요청)</label>
		        </div>
		        <div class="form-check">
		            <input class="form-check-input" type="radio" name="user_type"
		                   id="typePreManager" value="preManager" checked>
		            <label class="form-check-label" for="typePreManager">직원(승인요청)</label>
		        </div>
		    </c:if>
		</div>
			<div class="d-flex justify-content-between">
				<button type="submit" class="btn btn-primary">수정하기</button>
				<a href="/myUsage" class="btn btn-secondary">돌아가기</a>
			</div>
		</form>
		
		<!-- 회원 탈퇴 폼 -->
		<form id="profiledeleteForm" method="post" action="/profileEdit/delete">
			<button onclick="confirmDelete()" class="btn btn-primary">회원 탈퇴</button>
		</form>
		
	</div>

</body>
</html>