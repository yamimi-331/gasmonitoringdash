<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>대시보드</title>
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script type="text/javascript" src="../../resources/js/dashboard.js"></script>
<link href="../../resources/css/common.css?after" rel="stylesheet"
	type="text/css">
<link href="../../resources/css/dashboard.css?after" rel="stylesheet"
	type="text/css">
</head>
<body>
	<header>
		<h2 class="header-title">Dashboard</h2>
	</header>

	<!-- nav와 main을 가로로 나란히 배치하기위한 컨테이너 -->
	<div class="container">
		<!-- 좌측 네비게이션 start ============================= -->
		<nav>
			<c:choose>
				<c:when test="${not empty currentUserInfo}">
					<button class="header-button" onclick="location.href='/myUsage'">myUsage</button>
					<button class="header-button" onclick="logout()">logout</button>
				</c:when>
				<c:otherwise>
					<button class="header-button" onclick="location.href='/login'">Login</button>
				</c:otherwise>
			</c:choose>
			<c:if
				test="${currentUserInfo.user_type != null and (currentUserInfo.user_type == 'admin' or currentUserInfo.user_type == 'manager')}">
				<button class="header-button" onclick="location.href='/admin'">admin</button>
			</c:if>

			<ul>
				<li>메인 페이지</li>
				<li>다른페이지</li>
				<li>12131</li>
				<li>다른페이지</li>
				<li>12131</li>
				<li>다른페이지</li>
				<li>12131</li>
			</ul>
		</nav> <!-- 좌측 네비게이션 end ============================= -->

		<!-- main start ============================= -->
		<main>
			<!-- 대시보드 스크롤용 감싸는 div start =============================== -->
			<div class="dashboard-scroll-wrapper">
				<!-- 대시보드를 담은 컨테이너 start -------------------------------------- -->
				<div class="dashboard-container">
					<!-- 연도별 가스 공급량 차트 영역 Start ---------------------------------- -->
					<div class="dashboard">
						<div id="yearForm">
							<label for="year">연도 선택:</label> <select id="year" name="year"
								required>
								<option value="2020">2020</option>
								<option value="2021">2021</option>
								<option value="2022">2022</option>
								<option value="2023">2023</option>
								<option value="2024">2024</option>
								<option value="2025" selected>2025</option>
							</select>
						</div>
						<!-- 상단 차트 공간 -->
						<div class="charts-top">
							<div id="topLocalSupply"></div>
						</div>
						<!-- 연도별 전국 가스 공급량 차트 -->
						<div class="charts-top">
							<div class="charts-box">
								<canvas id="yearLocalSupply"></canvas>
							</div>
						</div>
					</div>
					<!-- 연도별 가스 공급량 차트 영역 End ---------------------------------- -->
					<!-- 가스 공급량 및 수요예측 차트 Start ------------------------------------------------ -->
					<div class="dashboard">
						<!-- 선택영역 -->
						<div class="controls">
							<div id="cityForm">
								<label for="city">지역 선택:</label> <select id="city" name="city"
									required>
									<option value="서울특별시" selected>서울특별시</option>
									<option value="인천광역시">인천광역시</option>
									<option value="경기도">경기도</option>
									<option value="부산광역시">부산광역시</option>
									<option value="대구광역시">대구광역시</option>
									<option value="광주광역시">광주광역시</option>
									<option value="대전광역시">대전광역시</option>
									<option value="울산광역시">울산광역시</option>
									<option value="세종특별자치시">세종특별자치시</option>
									<option value="강원특별자치도">강원특별자치도</option>
									<option value="충청북도">충청북도</option>
									<option value="충청남도">충청남도</option>
									<option value="전북특별자치도">전북특별자치도</option>
									<option value="전라남도">전라남도</option>
									<option value="경상북도">경상북도</option>
									<option value="경상남도">경상남도</option>
									<option value="제주특별자치도">제주특별자치도</option>
								</select> <label for="model">분석 모델 선택:</label> <select id="model"
									name="model" required>
									<option value="XGBoost" selected>XGBoost</option>
									<option value="Prophet">Prophet</option>
									<option value="LSTM">LSTM</option>
								</select> <label for="period">예측 기간:</label> <select id="period"
									name="period" required>
									<option value="3" selected>3개월</option>
									<option value="6">6개월</option>
									<option value="12">12개월</option>
								</select>
								<button type="button" onclick="fetchPrediction()">조회</button>
							</div>
							<p id="loading" style="display: none;">데이터를 불러오는 중입니다...</p>
							<p id="xgb-result"></p>
						</div>
						<!-- 차트 -->
						<div class="charts-top">
							<div class="charts-box">
								<canvas id="gasChart"></canvas>
							</div>
						</div>
					</div>
					<!-- 가스 공급량 및 수요예측 차트 End ------------------------------------------------ -->
					<!-- 지역/년도별 인구수 및 가스 공급량 차트 start ----------------------------------------------- -->
					<div class="dashboard">
						<div class="controls">
							<label for="city_detail">지역 선택:</label> <select id="city_detail"
								name="city" required>
								<option value="서울특별시" selected>서울특별시</option>
								<option value="인천광역시">인천광역시</option>
								<option value="경기도">경기도</option>
								<option value="부산광역시">부산광역시</option>
								<option value="대구광역시">대구광역시</option>
								<option value="광주광역시">광주광역시</option>
								<option value="대전광역시">대전광역시</option>
								<option value="울산광역시">울산광역시</option>
								<option value="세종특별자치시">세종특별자치시</option>
								<option value="강원특별자치도">강원특별자치도</option>
								<option value="충청북도">충청북도</option>
								<option value="충청남도">충청남도</option>
								<option value="전북특별자치도">전북특별자치도</option>
								<option value="전라남도">전라남도</option>
								<option value="경상북도">경상북도</option>
								<option value="경상남도">경상남도</option>
								<option value="제주특별자치도">제주특별자치도</option>
							</select>
						</div>

						<div class="charts-top">
							<!-- 지역/년도별 인구수 및 가스 공급량 차트 -->
							<div class="charts-box">
								<canvas id="populationSupply"></canvas>
							</div>
							<!-- 지역별 1인당 가스 사용량 차트 -->
							<div class="charts-box">
								<canvas id="personalGasUse"></canvas>
							</div>
						</div>

						<div class="controls">
							<h2>동계 한파일수 vs 가스사용량</h2>
							<select id="cold_year" name="cold_year" required>
								<option value="2020">2020</option>
								<option value="2021">2021</option>
								<option value="2022">2022</option>
								<option value="2023">2023</option>
								<option value="2024">2024</option>
								<option value="2025" selected>2025</option>
							</select> <select id="cold_city" name="cold_city" required>
								<option value="서울특별시" selected>서울특별시</option>
								<option value="인천광역시">인천광역시</option>
								<option value="경기도">경기도</option>
								<option value="부산광역시">부산광역시</option>
								<option value="대구광역시">대구광역시</option>
								<option value="광주광역시">광주광역시</option>
								<option value="대전광역시">대전광역시</option>
								<option value="울산광역시">울산광역시</option>
								<option value="세종특별자치시">세종특별자치시</option>
								<option value="강원특별자치도">강원특별자치도</option>
								<option value="충청북도">충청북도</option>
								<option value="충청남도">충청남도</option>
								<option value="전북특별자치도">전북특별자치도</option>
								<option value="전라남도">전라남도</option>
								<option value="경상북도">경상북도</option>
								<option value="경상남도">경상남도</option>
								<option value="제주특별자치도">제주특별자치도</option>
							</select>
						</div>
						<!-- 한파일수 & 공급량 차트 -->
						<div class="charts-box">
							<canvas id="coldDayChart" width="600" height="300"></canvas>
						</div>
					</div>
					<!-- 지역/년도별 인구수 및 가스 공급량 차트 end ------------------ -->
				</div>
				<!-- 대시보드를 담은 컨테이너 start -------------------------------------- -->
			</div>
			<!-- 대시보드 스크롤용 감싸는 div End =============================== -->
		</main>
		<!-- main end ============================= -->
	</div>
	<!-- nav와 main을 가로로 나란히 배치하기위한 컨테이너 End ---------- -->

	<footer></footer>
</body>

<!-- 로그아웃후 메세지 알람(일회성) -->
<c:if test="${not empty msg}">
	<script>
		alert('${msg}');
	</script>
</c:if>

</html>