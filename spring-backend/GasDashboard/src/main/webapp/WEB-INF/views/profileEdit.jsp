<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ page trimDirectiveWhitespaces="true" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>DashBoard</title>
<script src="https://t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
<script type="text/javascript" src="../../resources/js/profileEdit.js?after"></script>
<link href="../../resources/css/common.css?after" rel="stylesheet" type="text/css">
<link href="../../resources/css/user.css?after" rel="stylesheet" type="text/css">
</head>
<body>
	<header>
		<h2 class="header-title">회원정보 수정</h2>
	</header>
	<!-- nav와 main을 가로로 나란히 배치하기위한 컨테이너 -->
	<div class="container">
		<jsp:include page="/WEB-INF/views/common/nav.jsp" />
	<main>
		<div class="form-container">
			<!-- 회원정보 수정 폼 -->
			<form class="user-form" method="post" id="profileEditForm" action="/profileEdit">
				<div class="form-group">
					<label for="userId">사용자 아이디</label>
					<input class="input-area" type="text" id="userId" name="user_id" value="${currentUserInfo.user_id}" readonly>
				</div>
	
				<div class="form-group">
					<label for="userPw">비밀번호</label>
					<input class="input-area" type="password" id="userPw" name="user_pw" value="${currentUserInfo.user_pw}">
				</div>
	
				<div class="form-group">
					<label for="pwCheck">비밀번호 확인</label>
					<input type="password" class="input-area" id="pwCheck" name="pw_check">
					<small id="pwCheckMsg" class="form-text"></small>
				</div>

				<div class="form-group">
					<label for="userName">이름</label>
					<input class="input-area" type="text" id="userName" name="user_nm" value="${currentUserInfo.user_nm}">
				</div>
				
				<div class="form-group">
					<label for="user_addr">주소</label> 
					<input type="hidden" name="local_cd" id="local_cd">
					<div class="id-group">
						<input class="input-id" type="text" name="user_addr" id="user_addr" autocomplete="off"  value="${currentUserInfo.user_addr}" readonly>
	    				<button type="button" class="input-id-button" onclick="searchAddress()">주소 검색</button>
					</div>
				</div>
	
				<div class="form-group">
			    	<label>회원 유형</label>
			    	<div class="radio-group">
				        <div>
				        	<c:choose>
					        	<c:when test="${currentUserInfo.user_type == 'common'}">
					        		<input type="radio" name="user_type" id="typeCommon" value="common" checked>
						            <label for="typeCommon">일반</label>
					        	</c:when>
								<c:otherwise>
									<input type="radio" name="user_type" id="typeCommon" value="common">
						            <label for="typeCommon">일반</label>
								</c:otherwise>
				        	</c:choose>
				        </div>
				        <div>
				        	<c:choose>
					        	<c:when test="${currentUserInfo.user_type == 'commonM'}">
					        		<input type="radio" name="user_type" id="typeCommonM" value="commonM" checked>
						            <label for="typeCommonM">직원(승인요청)</label>
					        	</c:when>
					        	<c:when test="${currentUserInfo.user_type == 'manager'}">
					        		<input type="radio" name="user_type" id="typeManager" value="manager" checked>
						            <label for="typeManager">직원</label>
					        	</c:when>
								<c:otherwise>
									<input type="radio" name="user_type" id="typeCommonM" value="commonM">
						            <label for="typeCommonM">직원(승인요청)</label>
								</c:otherwise>
				        	</c:choose>
				        </div>
				        <div>
				        	<c:choose>
					        	<c:when test="${currentUserInfo.user_type == 'commonA'}">
					        		<input type="radio" name="user_type" id="typeCommonA" value="commonA" checked>
						            <label for="typeCommonA">관리자(승인요청)</label>
					        	</c:when>
					        	<c:when test="${currentUserInfo.user_type == 'managerA'}">
					        		<input type="radio" name="user_type" id="typeManagerA" value="managerA" checked>
						            <label for="typeManagerA">관리자(승인요청)</label>
					        	</c:when>
					        	<c:when test="${currentUserInfo.user_type == 'admin'}">
					        		<input type="radio" name="user_type" id="typeAdmin" value="admin" checked>
						            <label for="typeAdmin">관리자</label>
					        	</c:when>
					        	<c:when test="${ currentUserInfo.user_type == 'manager'}">
					        		<input type="radio" name="user_type" id="typeManagerA" value="managerA">
						            <label for="typeManagerA">관리자(승인요청)</label>
					        	</c:when>
								<c:otherwise>
									<input type="radio" name="user_type" id="typeCommonA" value="commonA">
						            <label for="typeCommonA">관리자(승인요청)</label>
								</c:otherwise>
				        	</c:choose>
				        </div>
			        </div>
			    </div>
				<div class="button-group">
					<button type="submit" class="submit-area">수정하기</button>
				</div>
			</form>

			<!-- 회원 탈퇴 폼 -->
			<form class="button-group" id="profiledeleteForm" method="post" action="/profileEdit/delete">
				<a href="javascript:void(0);" onclick="return confirmDelete()" class="del-account">회원 탈퇴</a>
			</form>
		</div>
	</main>
	</div>
	<footer></footer>
</body>
</html>