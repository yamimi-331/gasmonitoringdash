<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<script src="../../resources/js/test.js"></script>
</head>
<body>

	<div class="section">
		<h2>가스 예측 데이터 가져오기 (LSTM)</h2>
		<button onclick="fetchPrediction()">예측 데이터 가져오기</button>
		<canvas id="gasChart"></canvas>
	</div>

	<h2>XGBoost 예측 데이터 가져오기</h2>

	<label for="xgb-local">지역명:</label>
	<input type="text" id="xgb-local" value="서울특별시" />

	<label for="xgb-start">시작일자 (YYYY-MM-DD):</label>
	<input type="date" id="xgb-start" />

	<label for="xgb-end">종료일자 (YYYY-MM-DD):</label>
	<input type="date" id="xgb-end" />

	<button onclick="fetchXGBoostPrediction()">예측 데이터 가져오기</button>

	<div id="xgb-result">여기에 예측 결과가 표시됩니다...</div>

</body>
</html>