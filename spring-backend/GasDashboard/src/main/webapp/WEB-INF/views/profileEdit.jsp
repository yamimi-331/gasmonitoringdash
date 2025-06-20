<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
	<!-- 아이디 (중복 확인) -->
	<div class="form-group">
	    <label for="user_id">아이디</label>
	    <div class="id-check-group">
	        <input class="input-area" type="text" name="user_id" id="user_id" value="${userVO.user_id}" autocomplete="off">
	        <button type="button" onclick="checkDuplicateId()">중복확인</button>
	    </div>
	</div>
	
	<!-- 비밀번호 -->
	<div class="form-group">
	    <label for="user_pw">새 비밀번호</label>
	    <input class="input-area" type="password" name="user_pw" id="user_pw" autocomplete="new-password">
	</div>
	<div class="form-group">
	    <label for="user_pw_check">비밀번호 확인</label>
	    <input class="input-area" type="password" id="user_pw_check" autocomplete="new-password">
	</div>
	
	<!-- 이름 -->
	<div class="form-group">
	    <label for="user_nm">이름</label>
	    <input class="input-area" type="text" name="user_nm" id="user_nm" value="${userVO.user_nm}">
	</div>
	
	<!-- 지역 코드 (select) -->
	<div class="form-group">
	    <label for="local_cd">지역</label>
	    <select class="input-area" name="local_cd" id="local_cd">
	        <c:forEach var="region" items="${regionList}">
	            <option value="${region.cd}" <c:if test="${region.cd == userVO.local_cd}">selected</c:if>>${region.name}</option>
	        </c:forEach>
	    </select>
	</div>
	
	<!-- 주소 -->
	<div class="form-group">
	    <label for="user_addr">주소</label>
	    <input class="input-area" type="text" name="user_addr" id="user_addr" value="${userVO.user_addr}">
	</div>
	
	<!-- 사용자 유형 -->
	<div class="form-group">
	    <label for="user_type">회원 유형</label>
	    <select class="input-area" name="user_type" id="user_type">
	        <option value="common" <c:if test="${userVO.user_type == 'common'}">selected</c:if>>일반 사용자</option>
	        <option value="preManager" <c:if test="${userVO.user_type == 'preManager'}">selected</c:if>>직원</option>
	        <option value="preAdmin" <c:if test="${userVO.user_type == 'preAdmin'}">selected</c:if>>관리자</option>
	    </select>
	</div>

</body>
</html>