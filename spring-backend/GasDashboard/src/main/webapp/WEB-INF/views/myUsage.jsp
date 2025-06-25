<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ page trimDirectiveWhitespaces="true" %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>DashBoard</title>
<!-- Chart.js CDN -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script src="https://cdn.jsdelivr.net/npm/chartjs-plugin-datalabels"></script>
<link href="../../resources/css/common.css?after" rel="stylesheet" type="text/css">
<link href="../../resources/css/dashboard.css?after" rel="stylesheet" type="text/css">
<style>

/* inner-container는 nav 옆 공간 모두 차지, flex 컨테이너로 세로 정렬 */
/* .inner-container {
  display: flex;
  justify-content: center;  
  align-items: center;      
  box-sizing: border-box;
  padding: 20px;
} */

/* 
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
	font-size: 0.9em;
} */
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
		<h2 class="header-title">마이페이지</h2>
	</header>
	<div class="container">
		<jsp:include page="/WEB-INF/views/common/nav.jsp" />
		
		<!-- 고객님의 최근 (12개월) 월별 사용량 추이 & 가스사용량 비교 Start ----------------- -->
		<main class="board-page">
		<div class="inner-container">
			<div class="myusage-container">
			<!-- 🚩 Dashboard 1: 최근 12개월 사용량 추이 -->
			<div class="myusage-dashboard">
				<h2 class="main-title">고객님의 최근 (12개월) 월별 사용량 추이</h2>
				<div class="black-line"></div>
			
				<p>당월 사용량 : ${localUsage.currentMonthUsage}m³</p>
				<div class="charts-top">
					<div class="myusage-charts-box">
						<canvas id="recentUsageChart" width="740" height="370"></canvas>
					</div>
				</div>
			</div>
			
			<!-- 🚩 Dashboard 2: 지역 사용량 비교 -->
			<div class="myusage-dashboard">
				<h2 class="main-title">가스사용량 비교</h2>
				<div class="black-line"></div>
			
				<p>지역: ${localUsage.localNm}</p>
				<div class="charts-top">
					<div class="myusage-charts-box">
						<canvas id="localUsageComparison" width="740" height="370"></canvas>
					</div>
				</div>
			
				<div class="usage-feedback">
					<c:choose>
						<c:when test="${localUsage.currentMonthUsage lt localUsage.avgCurrentMonthPublicUsage}">
							<h2>이번 달 사용량이 지역 평균보다 낮습니다.</h2>
						</c:when>
			
						<c:when test="${localUsage.currentMonthUsage gt localUsage.avgCurrentMonthPublicUsage}">
							<h2>이번 달 사용량이 지역 평균보다 높습니다.</h2>
						</c:when>
			
						<c:otherwise>
							<h2>이번 달 사용량이 지역 평균과 같습니다.</h2>
						</c:otherwise>
					</c:choose>
				</div>
			</div>
			</div>
			
			
		<%-- 	<div class="table-box">
				<table>
					<colgroup>
						<col width="50%">
						<col width="50%">
					</colgroup>
					<tr>
						<th><h2 class="main-title">고객님의 최근 (12개월) 월별 사용량 추이</h2></th>
						<th><h2 class="main-title">가스사용량 비교</h2></th>
					</tr>
					<tr>
						<td>당월 사용량 : ${localUsage.currentMonthUsage}m³</td>
						<td>지역: ${localUsage.localNm}</td>
					</tr>
					<tr>
						<td><canvas id="recentUsageChart" width="740" height="370"></canvas></td>
						<td><canvas id="localUsageComparison" width="740" height="370"></canvas></td>
					</tr>
					<tr>
						<td colspan="2">
							<c:choose>
						        사용량이 평균보다 낮은 경우
						        <c:when test="${localUsage.currentMonthUsage lt localUsage.avgCurrentMonthPublicUsage}">
						            <h2>이번 달 사용량이 지역 평균보다 낮습니다.</h2>
						        </c:when>
						
						        사용량이 평균보다 높은 경우
						        <c:when test="${localUsage.currentMonthUsage gt localUsage.avgCurrentMonthPublicUsage}">
						            <h2>이번 달 사용량이 지역 평균보다 높습니다.</h2>
						        </c:when>
						
						        사용량이 평균과 같은 경우
						        <c:otherwise>
						            <h2>이번 달 사용량이 지역 평균과 같습니다.</h2>
						        </c:otherwise>
						    </c:choose>
						</td>
					</tr>
				</table>
			</div> --%>
		</div>
		<!-- 고객님의 최근 (12개월) 월별 사용량 추이 & 가스사용량 비교 End   ----------------- -->
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