<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>대시보드</title>
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<style>
body {
	margin: 0;
	font-family: sans-serif;
	background-color: #f5f5f5;
}

.dashboard {
	width: 70vw;
	margin: 40px auto;
	padding: 30px;
	background-color: #1e1e2f;
	border-radius: 12px;
	box-shadow: 0px 4px 10px rgba(0, 0, 0, 0, 1);
	box-sizing: border-box;
}

.header {
	display: flex;
	justify-content: space-between;
	align-items: center;
	margin-bottom: 30px;
}

.header h2 {
	color: white;
	margin: 0;
	font-size: 1.8rem;
	margin: 0;
}

.charts-top {
	display: flex;
	gap: 35px;
	margin-bottom: 40px;
	flex-wrap: wrap;
	justify-content: center;
}

.chart-box {
	position: relative;
	width: 45%; /* ✅ 한 줄에 2개 배치 (가로 여백 포함) */
	flex: 1 1 300px;
	aspect-ratio: 4/2.2;
	background-color: #e6e6e6;
	border-radius: 12px;
	display: flex;
	justify-content: center;
	align-items: center;
	padding: 0;
	box-sizing: border-box;
}

.chart-box img {
	width: 100%;
	height: 100%;
	object-fit: cover;
	border-radius: 10px;
	box-sizing: border-box;
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
	color: #333;
	z-index: 2; /* 이미지를 덮도록 */
}

/* 드롭다운 컨트롤 */
.controls {
	margin-bottom: 30px;
	display: flex;
	flex-wrap: wrap;
	align-items: center;
	gap: 20px;
}

.controls label {
	color: white;
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
	flex: 1 1 400px;
	min-width: 500px;
	aspect-ratio: 1.5/1;
	background-color: #f0f0f0;
	border-radius: 10px;
	padding: 15px;
	display: flex;
	align-items: center;
	justify-content: center;
	box-sizing: border-box;
	background-color: #f0f0f0;
}

.chart-container img {
	width: 100%;
	height: 100%;
	object-fit: cover;
	border-radius: 10px;
	box-sizing: border-box;
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
	tramsition: background-color 0.3s;
}

button:hover {
	background-color: #0056b3;
}
</style>
</head>
<body>
	<!-- 전체 대시보드 컨테이너 -->
	<div class="dashboard">
		<!-- 상단 헤더  -->
		<div class="header">
			<h2>📊 Dashboard</h2>
			<button>편집 완료</button>
		</div>

		<!-- 상단 차트 공간 -->
		<div class="charts-top">
			<div class="chart-box">
				<c:if test="${not empty visualizations}">
					<div class="chart-title">월별 추이</div>
					<img src="data:image/png;base64,${visualizations.monthly_trend}" />
				</c:if>
			</div>
			<div class="chart-box">
				<c:if test="${not empty visualizations}">
					<div class="chart-title">온도-공급량 관계</div>
					<img src="data:image/png;base64,${visualizations.temp_supply}" />
				</c:if>
			</div>

			<%-- 	<div class="chart-box">
				<c:if test="${not empty visualizations}">
					<div class="chart-title">지역별 패턴</div>
					<img src="data:image/png;base64,${visualizations.regional_pattern}" />
				</c:if>
			</div> --%>
		</div>


		<!-- 선택 컨트롤 -->
		<div class="controls">
			<label for="city">Select City:</label> <select id="city" name="city">
				<option value="" disabled selected>지역을 선택하세요</option>
				<option value="서울">서울</option>
				<option value="경기도">경기도</option>
				<option value="부산">부산</option>
				<option value="울산">울산</option>
			</select> <label for="model">Select Model:</label> <select id="model"
				name="model">
				<option value="" disabled selected>모델을 선택하세요</option>
				<option value=""></option>
				<option value=""></option>
				<option value=""></option>
			</select>
		</div>

		<!-- 하단 차트 3개 -->
		<div class="charts-bottom">
			<div class="chart-container">
				<img
					src="data:image/png;base64,${visualizations.supply_prediction_timeline_xgboost}" />
			</div>
			<div class="chart-container">
				<img
					src="data:image/png;base64,${visualizations.lstm_prediction_timeline}" />
			</div>
			<div class="chart-container">
				<img src="data:image/png;base64,${visualizations.regional_pattern}" />
			</div>
				<div class="chart-container">
				<img src= "data:image/png;base64,${visualizations.prophet_prediction_timeline}"/>
			</div>
		</div>
	</div>

	<!-- 예제 코드 -->
	<%-- 	<c:if test="${not empty models}">
		<h3>XGBoost</h3>
		<ul>
			<li>MSE: ${models.XGBoost.mse}</li>
			<li>RMSE: ${models.XGBoost.rmse}</li>
			<li>R²: ${models.XGBoost.r2}</li>
		</ul>

		<h3>Prophet</h3>
		<p>${models.Prophet.model}</p>

		<h3>LSTM</h3>
		<p>${models.LSTM.model}</p>
	</c:if>
 --%>

		<h2>시각화 결과</h2>
	<c:if test="${not empty visualizations}">
		<h3>월별 추이</h3>
		<img src="data:image/png;base64,${visualizations.monthly_trend}" />

		<h3>온도-공급량 관계</h3>
		<img src="data:image/png;base64,${visualizations.temp_supply}" />

		<h3>지역별 패턴</h3>
		<img src="data:image/png;base64,${visualizations.regional_pattern}" />

		<h3>예측 비교</h3>
		<img src="data:image/png;base64,${visualizations.prediction_comparison}" /> 
	</c:if>

	<%-- 	<c:if test="${not empty error}">

			src="data:image/png;base64,${visualizations.prediction_comparison}" />
</c:if>
	<c:if test="${not empty error}">
		<p style="color: red;">오류: ${error}</p>
	</c:if> --%>

	<!-- 	<script>
		const ctx1 = docu
	</script> -->


</body>

</html>