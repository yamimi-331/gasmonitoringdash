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
			<table border="1">
				<tr><th colspan="2">고객님의 최근 (12개월) 월별 사용량 추이</th><th>가스사용량 비교</th></tr>
				<tr><td>당월 사용량</td><td>{사용량값}M^3</td><td>지역: {}</td></tr>
				<tr><td colspan="2"><canvas id="recentUsageChart"></canvas></td><td><canvas id="localUsageComparison"></canvas></td></tr>
			</table>
		</div>
		<!-- 고객님의 최근 (12개월) 월별 사용량 추이 & 가스사용량 비교 End   ----------------- -->
	
	</div>
		
	<!-- 여긴 높이 보정용 푸터 입니다. -->
	<footer></footer>


<script>
  // Java에서 전달된 데이터를 JS 배열로 변환
  const recentUsage = [
    <c:forEach var="usage" items="${recentUsage}">
      { date: '${usage.usage_dt}', amount: ${usage.usage_amount} },
    </c:forEach>
  ];

  // 날짜와 값만 추출
  const labels = recentUsage.map(item => item.date);
  const data = recentUsage.map(item => item.amount);

  // 차트 생성
  const ctx = document.getElementById('recentUsageChart').getContext('2d');
  const chart = new Chart(ctx, {
    type: 'line',
    data: {
      labels: labels,
      datasets: [{
        label: '최근 12개월 가스 사용량',
        data: data,
        fill: false,
        borderColor: 'rgba(75, 192, 192, 1)',
        backgroundColor: 'rgba(75, 192, 192, 0.2)',
        tension: 0.2
      }]
    },
    options: {
      responsive: true,
      plugins: {
        legend: {
          position: 'top'
        },
        title: {
          display: true,
          text: '최근 12개월 월별 가스 사용량'
        }
      },
      scales: {
        y: {
          beginAtZero: true,
          title: {
            display: true,
            text: '사용량 (단위: ?)'
          }
        },
        x: {
          title: {
            display: true,
            text: '사용월'
          }
        }
      }
    }
  });
</script>
</body>
</html>