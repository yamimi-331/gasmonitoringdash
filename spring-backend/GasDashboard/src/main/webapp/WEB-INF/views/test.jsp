<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>

	<h2>가스 예측 데이터 가져오기 (LSTM)</h2>

	<button onclick="fetchPrediction()">예측 데이터 가져오기</button>

	<div id="result">여기에 예측 결과가 표시됩니다...</div>

	<h2>XGBoost 예측 데이터 가져오기</h2>

	<label for="xgb-local">지역명:</label>
	<input type="text" id="xgb-local" value="서울특별시" />

	<label for="xgb-start">시작일자 (YYYY-MM-DD):</label>
	<input type="date" id="xgb-start" />

	<label for="xgb-end">종료일자 (YYYY-MM-DD):</label>
	<input type="date" id="xgb-end" />

	<button onclick="fetchXGBoostPrediction()">예측 데이터 가져오기</button>

	<div id="xgb-result">여기에 예측 결과가 표시됩니다...</div>

	<script>
    async function fetchXGBoostPrediction() {
      const localName = document.getElementById("xgb-local").value;
      const startDate = document.getElementById("xgb-start").value;
      const endDate = document.getElementById("xgb-end").value;

      if (!localName || !startDate || !endDate) {
        alert("모든 입력값을 입력해주세요.");
        return;
      }

      const queryParams = new URLSearchParams({
        local_name: localName,
        start_date: startDate,
        end_date: endDate
      });

      try {
        const response = await fetch('http://localhost:8000/api/gas/xgboost-prediction?'+queryParams);
        const data = await response.json();
        document.getElementById("xgb-result").textContent = JSON.stringify(data, null, 2);
      } catch (error) {
        document.getElementById("xgb-result").textContent = "에러 발생: " + error;
      }
    }

    async function fetchPrediction() {
      const region = '서울특별시'; // 원하는 지역명
      const future_months = 3;
      const recent_months = 6;
      const sequence_length = 12;

      const queryParams = new URLSearchParams({
        region,
        future_months,
        recent_months,
        sequence_length
      });

      try {
        const response = await fetch('http://localhost:8000/api/gas/lstm-prediction?'+queryParams);
        const data = await response.json();

        const resultDiv = document.getElementById("result");
        resultDiv.textContent = JSON.stringify(data, null, 2);
      } catch (error) {
        document.getElementById("result").textContent = "에러 발생: " + error;
      }
    }
  </script>
</body>
</html>