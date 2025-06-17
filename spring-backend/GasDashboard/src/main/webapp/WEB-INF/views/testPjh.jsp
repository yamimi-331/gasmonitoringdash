<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
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
	
	<p>선택된 지역: <span id="selectedCityText">없음</span></p>
	<p>선택된 모델: <span id="selectedModelText">없음</span></p>
	
	<p id="loading" style="display:none;">데이터를 불러오는 중입니다...</p>
	<p id="xgb-result"></p>
	<canvas id="gasChart"></canvas>
	
	<!-- <img id="localChart" alt="차트 이미지" />
	<img id="modelChart" alt="차트 이미지" /> -->


<script type="text/javascript">
let gasChart;
async function fetchPrediction() {
	const selectedCity = document.getElementById("city").value;
	const selectedModel = document.getElementById("model").value;
	const selectedPeriod = document.getElementById("period").value;
	
	const selectedCityText = document.getElementById("selectedCityText");
	const selectedModelText = document.getElementById("selectedModelText");
	
	const errorMsg = document.getElementById("xgb-result");
	errorMsg.textContent = "";


	if (!selectedCity) {
		alert("지역을 선택하세요.");
		return;
	}
	if (!selectedModel) {
		alert("분석 모델을 선택하세요.");
		return;
	}

	// 디버깅용 로그
	console.log("선택된 타입:", selectedCity);
	console.log("선택된 모델:", selectedModel);
	
	// 기준일
	const baseDateStr = '2025-03-01';
	const baseDate = new Date(baseDateStr);

	// start_date: 전년도 1월 1일 (2024-01-01)
	const startDate = new Date(baseDate.getFullYear() - 1, 0, 1);
	const startDateStr = startDate.toISOString().slice(0, 10);

	// end_date: 기준일 + period 개월
	const period = Number(selectedPeriod);
	const endDate = new Date(baseDate);
	endDate.setMonth(endDate.getMonth() + period);
	const endDateStr = endDate.toISOString().slice(0, 10);
	
	const queryParams = new URLSearchParams({
		local_name: selectedCity,
		start_date: startDateStr,
		end_date: endDateStr
	});
	
	const loading = document.getElementById("loading");
	loading.style.display = "inline";
	
	try {
		const response = await fetch('http://localhost:8000/api/gas/xgboost-prediction?'+queryParams);
		const data = await response.json();
	    const labels = Object.keys(data);
        const actual = labels.map(key => data[key].actual);
        const pastPred = labels.map(key => data[key].past_pred);
        const futurePred = labels.map(key => data[key].future_pred);

        // 기존 차트 제거
        if (gasChart) gasChart.destroy();

        const ctx = document.getElementById('gasChart').getContext('2d');
        gasChart = new Chart(ctx, {
          type: 'bar',
          data: {
            labels: labels,
            datasets: [
              {
                label: '실제 공급량',
                data: actual,
                backgroundColor: 'rgba(54, 162, 235, 0.7)'
              },
              {
                label: '과거 예측',
                data: pastPred,
                backgroundColor: 'rgba(255, 206, 86, 0.7)'
              },
              {
                label: '미래 예측',
                data: futurePred,
                backgroundColor: 'rgba(75, 192, 192, 0.7)'
              }
            ]
          },
          options: {
            responsive: true,
            plugins: {
              title: {
                display: true,
                text: '가스 공급량 및 수요 예측',
                font: { size: 18 }
              },
              tooltip: {
                mode: 'index',
                intersect: false
              }
            },
            scales: {
              x: {
                title: { display: true, text: '월' }
              },
              y: {
                title: { display: true, text: '공급량' },
                beginAtZero: true
              }
            }
          }
        });
		} catch (error) {
			console.error(error);
		} finally {
			loading.style.display = "none";
		}
	}
</script>
</body>
</html>