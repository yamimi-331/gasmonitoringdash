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
	<div class="container">
	
		<!-- 상단 정보표시 헤더 Start ------------------------- -->
		<div class="inner-container">
			<div class="head-box">
				<!-- 메인화면 글씨 -->
				<div class="title-container"><h2>마이 페이지</h2></div>
				<!-- 버튼 내비게이션 -->
				<div class="header-container">
					<!-- 사용자 소개 -->
					<div class="header-inner-container">
						<span>${currentUserNm} 님, 환영합니다.</span> 
					</div>
					<!-- 로그아웃 및 기능 버튼 -->
					<div class="header-inner-container">
						<button class="green-btn-2" onclick="logout()">로그아웃</button>
						<button class="green-btn-2" onclick="location.href='/'">메인페이지</button>
					</div>
				</div>
			</div>
		</div>
		<!-- 상단 정보표시 헤더 end   ------------------------- -->
		
		<!-- 고객님의 최근 (12개월) 월별 사용량 추이 & 가스사용량 비교 Start ----------------- -->
		<div class="inner-container">
			<table>
				<tr><th colspan="2">고객님의 최근 (12개월) 월별 사용량 추이</th><th>가스사용량 비교</th></tr>
				<tr><td>당월 사용량</td><td>${localUsage.currentMonthUsage}M^3</td><td>지역: ${localUsage.localNm}</td></tr>
				<tr><td colspan="2"><canvas id="recentUsageChart" width="500" height="250"></canvas></td><td><canvas id="localUsageComparison" width="500" height="250"></canvas></td></tr>
			</table>
		</div>
		<!-- 고객님의 최근 (12개월) 월별 사용량 추이 & 가스사용량 비교 End   ----------------- -->
	
	</div>
		
	<!-- 여긴 높이 보정용 푸터 입니다. -->
	<footer></footer>

<script>
	// 응답받은 데이터 EL 형식으로 저장
	const recentUsageData = [
	    <c:forEach var="usage" items="${recentUsage}" varStatus="status">
	      {
	        date: '${usage.usage_dt}',
	        amount: ${usage.usage_amount}
	      }<c:if test="${!status.last}">,</c:if>
	    </c:forEach>
	  ];
	const localUsageData = {
  		avgCurrentMonthUsage: ${localUsage.avgCurrentMonthUsage},
  		currentMonthUsage: ${localUsage.currentMonthUsage},
 	 	lastYearSameMonthUsage: ${localUsage.lastYearSameMonthUsage},
  		yearlyAvgUsage: ${localUsage.yearlyAvgUsage}
	};
</script>
<script src="../resources/js/usage.js"></script>
</body>
</html>