<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<style>
    .circle_container{
        display: flex;
        justify-content: center;
        align-items: center;
        gap: 20px;
        margin-top: 50px;
    }
	.inner_circle{
        width: 100px; 
        height: 100px; 
        background-color: rgb(66, 108, 148); 
        border-radius: 50%; 
        display: flex;
        align-items: center;
        justify-content: center;
    }
    .inner_circle2{
        width: 130px; 
        height: 130px; 
        background-color: rgb(66, 108, 148); 
        border-radius: 50%; 
        display: flex;
        align-items: center;
        justify-content: center;
    }
	a{text-decoration: none; color: white; font-weight: bold;}
</style>
<body>
	<c:set var="userType" value="${ currentUserInfo }"/>	
	<c:if test="${ userType !=null }">
		<div class="circle_container">
			${ currentUserInfo.user_nm }님, 환영합니다.
			<button class="green-btn-2" onclick="logout()">로그아웃</button>
		</div>
	</c:if>
	<div class="circle_container">
        <a href="javascript:void(0);" onclick="goToMyUsagePage()"><div class="inner_circle">내 정보 보기</div></a>
        <a href="/dashboard"><div class="inner_circle2">대시보드<br>바로가기</div></a>
        <a href="javascript:void(0);" onclick="goToAdminPage()"><div class="inner_circle">관리자<br>로그인</div></a>
    </div>
    <script>
		const isLoggedIn = ${not empty currentUserInfo.user_nm};
		function goToMyUsagePage() {
			if (isLoggedIn) {
				location.href = '/myUsage';
			} else {
				alert('로그인이 필요합니다.');
				location.href = '/login';
			}
		}
		function goToAdminPage() {
			if (isLoggedIn) {
				location.href = '/admin';
			} else {
				alert('로그인이 필요합니다.');
				location.href = '/login';
			}
		}
		function logout() {
			let isLogout = confirm("정말 로그아웃 하시겠습니까?");
			if (isLogout) {
				// 확인 눌렀을 때 로그아웃 페이지로 이동
				window.location.href = "/logout";
			}
		}
    </script>
    <!-- 데이터 저장 alert메세지 -->
	<c:if test="${not empty msg}">
		<script>
        	alert('${msg}');
    	</script>
	</c:if>
</body>
</html>