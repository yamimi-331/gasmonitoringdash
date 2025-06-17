<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script type="text/javascript" src="../../resources/js/test.js"></script>
</head>
<body>
	<form method="get" id="cityForm" onsubmit="return false;">
		<label for="city">지역 선택:</label>
		<select id="city" name="city" required>
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
		</select>
		<label for="model">분석 모델 선택:</label>
		<select id="model" name="model" required>
			<option value="" disabled selected>모델을 선택하세요</option>
			<option value="XGBoost">XGBoost</option>
			<option value="Prophet">Prophet</option>
			<option value="LSTM">LSTM</option>
		</select>
		<label for="period">예측 기간:</label>
		<select id="period" name="period" required>
			<option value="3" selected>3개월</option>
			<option value="6">6개월</option>
			<option value="12">12개월</option>
		</select>
		<button type="button" onclick="fetchPrediction()">조회</button>
	</form>
	<p id="loading" style="display:none;">데이터를 불러오는 중입니다...</p>
	<p id="xgb-result"></p>
	<canvas id="gasChart"></canvas>
	
</body>
</html>