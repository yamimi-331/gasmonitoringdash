<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
<link href="../../resources/css/common.css" rel="stylesheet"/>
</head>
<style>
    .circle-container{
        display: flex;
        justify-content: center;
        align-items: center;
        gap: 20px;
    }
	.inner-circle{
        width: 160px; 
        height: 160px; 
        background-color: rgb(66, 108, 148); 
        border-radius: 50%; 
        display: flex;
        align-items: center;
        justify-content: center;
    }
    .inner-circle-big{
        width: 200px; 
        height: 200px; 
        background-color: rgb(66, 108, 148); 
        border-radius: 50%; 
        display: flex;
        align-items: center;
        justify-content: center;
    }
	a{text-decoration: none; color: white; font-weight: bold;}
	a.inner-circle:hover, a.inner-circle-big:hover {
	    background-color: rgb(50, 90, 130);
	    cursor: pointer;
	    transform: scale(1.05);
	    transition: 0.2s;
	}
	.inner-circle, .inner-circle-big {
	    text-align: center;
	    flex-direction: column;
	}
	
	.text-center{
	text-align: center;
	}
</style>
<body>
	<header>
		<c:set var="userType" value="${ currentUserInfo }"/>	
		<div>
			<h3 class="header-title">가스 공급량 및 수요 예측 모니터링 대시보드</h3>
		</div>
		<c:if test="${ userType !=null }">
			<div class="text-center">
				${ currentUserInfo.user_nm }님, 환영합니다.
				<button onclick="logout()">로그아웃</button>
			</div>
		</c:if>
	</header>
	
	<main>
		<div class="circle-container">
	        <a href="javascript:void(0);" class="inner-circle" onclick="goToMyUsagePage()">내 정보 보기</a>
	        <a href="/dashboard" class="inner-circle-big" >대시보드<br>바로가기</a>
	        <a href="javascript:void(0);" class="inner-circle" onclick="goToAdminPage()">관리자<br>로그인</a>
	    </div>
	</main>
    
	<footer></footer>
    
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