<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
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
		<button type="button" onclick="yearSelect()">조회</button>
	</form>
	<form method="get" id="yearForm" onsubmit="return false;">
		<label for="year">연도 선택:</label>
		<select id="year" name="year" required>
			<option value="" disabled>연도를 선택하세요</option>
			<option value="2020">2020</option>
			<option value="2021">2021</option>
			<option value="2022">2022</option>
			<option value="2023">2023</option>
			<option value="2024">2024</option>
			<option value="2025" selected>2025</option>
		</select>
	</form>
	<p id="loading" style="display:none;">데이터를 불러오는 중입니다...</p>
	<p id="xgb-result"></p>
	<canvas id="gasChart"></canvas>
	
<script>
let gasChart;

document.addEventListener("DOMContentLoaded", () => {
	const yearSelect = document.getElementById("year");
	yearSelect.addEventListener("change", () => {
		const selectedYear = yearSelect.value;
		yearSelect(selectedYear);
	});
	// 초기 호출
	yearSelect("2025");
	});

async function yearSelect(year) {
	const loading = document.getElementById("loading");
	loading.style.display = "inline";
	
	try {
		const response = await fetch('http://localhost:8000/api/gas/yearsupply?year=' + year);
		data = await response.json();

		const yearData = data[year];
		const labels = Object.keys(yearData);
		const supplyValues = Object.values(yearData);
		
		const regionColors = {
			"서울특별시": "rgba(54, 162, 235, 0.7)",
			"경기도": "rgba(75, 192, 192, 0.7)",
			"인천광역시": "rgba(255, 159, 64, 0.7)",
			"부산광역시": "rgba(153, 102, 255, 0.7)",
			"대구광역시": "rgba(255, 99, 132, 0.7)",
			"광주광역시": "rgba(255, 206, 86, 0.7)",
			"대전광역시": "rgba(201, 203, 207, 0.7)",
			"울산광역시": "rgba(100, 149, 237, 0.7)",
			"세종특별자치시": "rgba(255, 105, 180, 0.7)",
			"강원특별자치도": "rgba(139, 195, 74, 0.7)",
			"충청북도": "rgba(255, 193, 7, 0.7)",
			"충청남도": "rgba(121, 85, 72, 0.7)",
			"전북특별자치도": "rgba(96, 125, 139, 0.7)",
			"전라남도": "rgba(0, 188, 212, 0.7)",
			"경상북도": "rgba(255, 87, 34, 0.7)",
			"경상남도": "rgba(63, 81, 181, 0.7)",
			"제주특별자치도": "rgba(0, 150, 136, 0.7)"
		};
		const backgroundColors = labels.map(label => regionColors[label] || 'rgba(200,200,200,0.7)');

		if (gasChart) gasChart.destroy();

		const ctx = document.getElementById('gasChart').getContext('2d');
		gasChart = new Chart(ctx, {
			type: 'bar',
			data: {
			labels: labels,
			datasets: [
					{
					label: '총 공급량',
					data: supplyValues,
					backgroundColor: backgroundColors
					}
				]
			},
			options: {
				responsive: true,
				plugins: {
					title: {
					display: true,
					text: '지역별 가스 총 공급량',
					font: { size: 18 }
					},
					tooltip: {
					mode: 'index',
					intersect: false
					}
				},
				scales: {
					x: {
						title: { display: true, text: '지역' }
					},
					y: {
						title: { display: true, text: '총 공급량(m³)' },
						beginAtZero: true
					}
				}
			}
		});
	} catch (error) {
		alert("데이터 가져오기 오류: " + error);
	}finally {
		loading.style.display = "none";
	}
}

</script>
</body>
</html>