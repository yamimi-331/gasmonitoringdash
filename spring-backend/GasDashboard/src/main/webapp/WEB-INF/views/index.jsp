<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
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
	<div class="circle_container">
        <a href="javascript:void(0);" onclick="goToMyUsagePage()"><div class="inner_circle">내 정보 보기</div></a>
        <a href="/dashboard"><div class="inner_circle2">대시보드<br>바로가기</div></a>
        <a href="javascript:void(0);" onclick="goToAdminPage()"><div class="inner_circle">관리자<br>로그인</div></a>
    </div>
    <script>
		const isLoggedIn = ${not empty currentUserNm};
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
    </script>
</body>
</html>