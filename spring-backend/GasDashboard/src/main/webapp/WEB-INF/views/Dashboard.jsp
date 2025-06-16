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
	max-width: 1200px;
	margin: 40px auto;
	padding: 20px;
	background-color: #fff;
	border-radius: 12px;
	box-shadow: 0px 4px 10px rgba(0, 0, 0, 0, 1);
}

.header {
	display: flex;
	justify-content: space-between;
	align-items: center;
	margin-bottom: 20px;
}

.header h2 {
	margin: 0;
}

.charts-top {
	display: flex;
	gap: 20px;
}

.chart-box {
	flex: 1;
	height: 200px;
	background-color: #e6e6e6;
	display: flex;
	justify-content: center;
	align-items: center;
	border-radius: 8px;
	font-size: 1.1rem;
}

.controls {
	margin-bottom: 20px;
}

.controls label {
	margin-right: 8px;
}

.controls select {
	padding: 6px 10px;
	border-radius: 6px;
	border: 1px solid #ccc;
}

.charts-bottom {
	display: flex;
	gap: 20px;
	flex-wrap: wrap;
}

.chart-container {
	flex: 1;
	min-width: 300px;
	width: 300px;
	background-color: #f0f0f0;
	border-radius: 10px;
	padding: 10px;
}

canvas {
	width: 100%;
	height: 100%;
}

button {
	padding: 6px 14px;
	background-color: #007bff;
	color: white;
	border: none;
	border-radius: 6px;
	cursor: pointer;
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
			<div class="chart-box">차트1</div>
			<div class="chart-box">차트2(예정)</div>
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
		<div class="chart-bottom">
			<div class="chart-container">
				<canvas id="chart1"></canvas>
			</div>
			<div class="chart-container">
				<canvas id="chart2"></canvas>
			</div>
			<div class="chart-container">
				<canvas id="chart3"></canvas>
			</div>
		</div>
	</div>
	
	<!-- 예제 코드 -->
	<c:if test="${not empty models}">
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


	<h2>시각화 결과</h2>
	<c:if test="${not empty visualizations}">
		<h3>월별 추이</h3>
		<img src="data:image/png;base64,${visualizations.monthly_trend}" />

		<h3>온도-공급량 관계</h3>
		<img src="data:image/png;base64,${visualizations.temp_supply}" />

		<h3>지역별 패턴</h3>
		<img src="data:image/png;base64,${visualizations.regional_pattern}" />

		<h3>예측 비교</h3>
		<img
			src="data:image/png;base64,${visualizations.prediction_comparison}" />
		<h3>예측 비교2</h3>
		<img
			src="data:image/png;base64,${visualizations.supply_prediction_timeline}" />
	</c:if>

	<c:if test="${not empty error}">
		<p style="color: red;">오류: ${error}</p>
	</c:if>
	
	<script>
		const ctx1 = docu
	</script>
	

</body>

</html>