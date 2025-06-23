<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
<!-- Chart.js CDN -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script src="https://cdn.jsdelivr.net/npm/chartjs-plugin-datalabels"></script>
<link href="../../resources/css/common.css?after" rel="stylesheet" type="text/css">
<style>

/* inner-container는 nav 옆 공간 모두 차지, flex 컨테이너로 세로 정렬 */
.inner-container {
  display: flex;
  justify-content: center;  /* 가로 가운데 정렬 */
  align-items: center;      /* 세로 가운데 정렬 */
  border: 2px solid black;
  box-sizing: border-box;
  padding: 20px;
}

.header-title{
	margin: 0;
	text-align: center;
}
table{
	margin: 20px;
}
table th{
	font-size: 1.5em;
	padding-bottom: 15px;
}
table td{
	padding: 0 20px;
}
table td[colspan="2"]{
	text-align: center;
}
</style>
<script>
	function logout() {
		let isLogout = confirm("정말 로그아웃 하시겠습니까?");
		if (isLogout) {
			// 확인 눌렀을 때 로그아웃 페이지로 이동
			window.location.href = "/logout";
		}
	}
</script>
</head>
<body>
	<header>
		<h2 class="header-title">마이 페이지</h2>
	</header>
	<div class="container">
		<!-- 좌측 네비게이션 Start ------------------------- -->
		<nav class="board-page">
			<div class="head-box">
				<!-- 버튼 내비게이션 -->
				<div>
					<!-- 사용자 소개 -->
					<div>
						<span>${currentUserInfo.user_nm} 님, 환영합니다.</span> 
					</div>
					<!-- 로그아웃 및 기능 버튼 -->
					<div>
						<button onclick="logout()">로그아웃</button>
						<button onclick="location.href='/'">메인페이지</button>
						<button onclick="location.href='/profileEdit'">회원정보수정</button>
					</div>
				</div>
			</div>
		</nav>
		<!-- 좌측 네비게이션 end   ------------------------- -->
		
		<!-- 고객님의 최근 (12개월) 월별 사용량 추이 & 가스사용량 비교 Start ----------------- -->
		<main class="board-page">
		<div class="inner-container">
			<div class="table-box">
				<table>
					<colgroup>
						<col width="50%">
						<col width="50%">
					</colgroup>
					<tr>
						<th>고객님의 최근 (12개월) 월별 사용량 추이</th>
						<th>가스사용량 비교</th>
					</tr>
					<tr>
						<td>당월 사용량 : ${localUsage.currentMonthUsage}m³</td>
						<td>지역: ${localUsage.localNm}</td>
					</tr>
					<tr>
						<td><canvas id="recentUsageChart" width="700" height="350"></canvas></td>
						<td><canvas id="localUsageComparison" width="700" height="350"></canvas></td>
					</tr>
					<tr>
						<td colspan="2">
							<c:choose>
						        <%-- 사용량이 평균보다 낮은 경우 --%>
						        <c:when test="${localUsage.currentMonthUsage lt localUsage.avgCurrentMonthPublicUsage}">
						            <p>이번 달 사용량이 지역 평균보다 낮습니다.</p>
						        </c:when>
						
						        <%-- 사용량이 평균보다 높은 경우 --%>
						        <c:when test="${localUsage.currentMonthUsage gt localUsage.avgCurrentMonthPublicUsage}">
						            <p>이번 달 사용량이 지역 평균보다 높습니다.</p>
						        </c:when>
						
						        <%-- 사용량이 평균과 같은 경우 --%>
						        <c:otherwise>
						            <p>이번 달 사용량이 지역 평균과 같습니다.</p>
						        </c:otherwise>
						    </c:choose>
						</td>
					</tr>
				</table>
			</div>
		</div>
		<!-- 고객님의 최근 (12개월) 월별 사용량 추이 & 가스사용량 비교 End   ----------------- -->
		
		<!-- 내 사용량에 관한 코멘트 Start -----------------
		<div class="inner-container">
		    <c:choose>
		        <%-- 사용량이 평균보다 낮은 경우 --%>
		        <c:when test="${localUsage.currentMonthUsage lt localUsage.avgCurrentMonthPublicUsage}">
		            <p>이번 달 사용량이 지역 평균보다 낮습니다.</p>
		        </c:when>
		
		        <%-- 사용량이 평균보다 높은 경우 --%>
		        <c:when test="${localUsage.currentMonthUsage gt localUsage.avgCurrentMonthPublicUsage}">
		            <p>이번 달 사용량이 지역 평균보다 높습니다.</p>
		        </c:when>
		
		        <%-- 사용량이 평균과 같은 경우 --%>
		        <c:otherwise>
		            <p>이번 달 사용량이 지역 평균과 같습니다.</p>
		        </c:otherwise>
		    </c:choose>
		</div>
		내 사용량에 관한 코멘트 End ----------------- -->
	</main>
	</div>
		
	<!-- 여긴 높이 보정용 푸터 입니다. -->
	<footer></footer>
	
	<c:if test="${not empty msg}">
   	 	<script>
        	alert('${msg}');
    	</script>
	</c:if>
	<script>
		const recentUsageData = [
		    <c:forEach var="usage" items="${recentUsage}" varStatus="status">
		      {
		        date: '${usage.usage_dt}',
		        amount: ${usage.usage_amount}
		      }<c:if test="${!status.last}">,</c:if>
		    </c:forEach>
		  ];
		const localUsageData = {
			avgCurrentMonthPublicUsage: ${localUsage.avgCurrentMonthPublicUsage},
	  		currentMonthUsage: ${localUsage.currentMonthUsage},
	 	 	lastYearSameMonthUsage: ${localUsage.lastYearSameMonthUsage},
	  		yearlyAvgUsage: ${localUsage.yearlyAvgUsage}
		};
	</script>
<script src="../resources/js/usage.js"></script>
</body>
</html>