<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>대시보드</title>
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script type="text/javascript" src="../../resources/js/test.js"></script>
<style>
body {
	margin: 0;
	font-family: sans-serif;
	background-color: #5c72a5;
}

.dashboard {
	width: 70vw;
	margin: 40px auto;
	padding: 30px;
	background-color: #ffffff;
	border-radius: 12px;
	box-shadow: 0px 4px 10px rgba(0, 0, 0, 0.1);
	box-sizing: border-box;
	border-radius: 12px;
}

.header {
	text-align: center;
	display: flex;
	justify-content: space-between;
	align-items: center;
	margin-bottom: 30px;
}

.header h2 {
	color: black;
	margin: 0;
	font-size: 1.8rem;
}

.charts-top {
	display: flex;
	gap: 35px;
	margin-bottom: 40px;
	flex-wrap: wrap;
	justify-content: center;
}

.charts-box {
	box-shadow: 0 6px 16px rgba(0, 0, 0, 0.2); /* 기존보다 저 진하고 넓은 그림자 */
	transition: box-shadow 0.3s ease;
	position: relative;
	width: 45%;
	height: auto;
	min-height: 180px;
	flex: 1 1 300px;
	aspect-ratio: 4/2.2;
	background-color: #d6d5d9;
	border-radius: 12px;
	display: flex;
	padding: 0;
	flex: 1 1 300px;
}

.charts-box2 {
	box-shadow: 0 6px 16px rgba(0, 0, 0, 0.2); /* 기존보다 저 진하고 넓은 그림자 */
	transition: box-shadow 0.3s ease;
	position: relative;
	width: 45%;
	height: auto;
	min-height: 180px;
	flex: 1 1 300px;
	aspect-ratio: 4/2.2;
	background-color: #d6d5d9;
	color: white;
	border-radius: 12px;
	display: flex;
	padding: 0;
	flex: 1 1 300px;
}

#gasChart {
	width: 100%;
	height: 100%;
	background-color: #d6d5d9;
	object-fit: cover;
	border-radius: 10px;
	box-sizing: border-box;
	object-fit: cover;
}

.chart-title {
	position: absolute;
	top: 12px;
	left: 12px;
	background-color: rgba(255, 255, 255, 0.7); /* 배경 흰색 반투명 */
	padding: 6px 12px;
	border-radius: 6px;
	font-weight: bold;
	font-size: 1.1rem;
	/* color: #333; */
	z-index: 2; /* 이미지를 덮도록 */
}

/* 드롭다운 컨트롤 */
.controls {
	margin-bottom: 30px;
	display: flex;
	flex-wrap: wrap;
	align-items: center;
	/* gap: 20px; */
}

.controls label {
	color: black;
	font-weight: 500;
}

.controls select {
	padding: 8px 14px;
	border-radius: 8px;
	border: 1px solid #ccc;
	font-size: 1rem;
}

/* 하단 차트 컨테이너 */
.charts-bottom {
	display: flex;
	gap: 20px;
	flex-wrap: wrap;
	justify-content: center;
}

.chart-container {
	width: calc(33.333% - 50px); /* 3개 배치, 좌우 여백 고려 */
	min-width: 250px;
	aspect-ratio: 1.5/1;
	background-color: #f0f0f0;
	border-radius: 10px;
	padding: 15px;
	display: flex;
	align-items: center;
	justify-content: center;
	box-sizing: border-box;
	margin: 15px;
}

.chart-container img {
	width: 100%;
	height: 100%;
	object-fit: cover;
	border-radius: 10px;
	box-sizing: border-box;
}

@media ( max-width : 1000px) {
	.chart-container {
		width: calc(50% - 30%)
	}
}

@media ( max-width : 600px) {
	.chart-container {
		width: 100%;
	}
}

/* 버튼 스타일 */
button {
	padding: 8px 18px;
	background-color: #007bff;
	color: white;
	border: none;
	border-radius: 8px;
	cursor: pointer;
	font-size: 1rem;
	transition: background-color 0.3s;
}

button:hover {
	background-color: #0056b3;
}

.chart-top label {
	color: white;
}

.dashboard>h2 {
	color: blue;
	display: flex;
	margin-bottom: 10px;
}
</style>
</head>
<body>
	<!-- 전체 대시보드 컨테이너 -->
	<div class="dashboard">
		<!-- 상단 헤더  -->
		<div class="header">
			<h2>📊 Dashboard</h2>
			<button class="header-button">Login</button>
		</div>


		<!-- 상단 차트 공간 -->
		<h2>지역별 가스 사용량</h2>
		<div class="controls">

			<form method="get" id="cityForm" onsubmit="return false;">
				<label for="city">지역 선택:</label> <select id="city" name="city"
					required>
					<option value="" disabled selected>지역을 선택하세요</option>
					<option value="서울특별시">서울특별시</option>
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
					<option value="" disabled selected>모델을 선택하세요</option>
					<option value="XGBoost">XGBoost</option>
					<option value="Prophet">Prophet</option>
					<option value="LSTM">LSTM</option>
				</select> <label for="period">예측 기간:</label> <select id="period"
					name="period" required>
					<option value="3" selected>3개월</option>
					<option value="6">6개월</option>
					<option value="12">12개월</option>
				</select>
				<button type="button" onclick="fetchPrediction()">조회</button>
			</form>
			<p id="loading" style="display: none;">데이터를 불러오는 중입니다...</p>
			<p id="xgb-result"></p>

		</div>

		<div class="charts-top">

			<div class="charts-box">
				<canvas id="gasChart"></canvas>
			</div>
			<div class="charts-box2">
				<canvas id="gasChart2"></canvas>
			</div>
		</div>
		<!-- 입력 영역 2: 하단 체크 앞 -->
		<div class="controls">
			<label for="city">Select City:</label> <select id="city2" name="city">
				<option value="" disabled selected>지역을 선택하세요</option>
				<option value="서울">서울</option>
				<option value="경기도">경기도</option>
				<option value="부산">부산</option>
				<option value="울산">울산</option>
			</select>
		</div>

		<div class="charts-bottom">
			<div class="chart-container">
				<img
					src="data:image/png;base64,${visualizations.lstm_prediction_timeline}" />
			</div>
			<div class="chart-container">
				<img src="data:image/png;base64,${visualizations.regional_pattern}" />
			</div>
			<div class="chart-container">
				<img
					src="data:image/png;base64,${visualizations.prophet_prediction_timeline}" />
			</div>
		</div>





		<script>
			let gasChart = null;
		</script>
</body>


</html>