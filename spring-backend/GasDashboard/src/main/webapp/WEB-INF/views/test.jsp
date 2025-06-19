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
	<div>
		<div>
			<h2>동계 한파일수 vs 가스사용량</h2>
			<select id="year" name="year" required>
				<option value="" disabled selected>연도를 선택하세요</option>
				<option value="2020">2020</option>
				<option value="2021">2021</option>
				<option value="2022">2022</option>
				<option value="2023">2023</option>
				<option value="2024">2024</option>
				<option value="2025">2025</option>
			</select>
			<select id="city_detail" name="city_detail" required>
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
		</div>
		<canvas id="correlationChart" width="600" height="300"></canvas>
	</div>


<script>
window.addEventListener("DOMContentLoaded", () => {
	  const citySelect = document.getElementById("cold_city");
	  const yearSelect = document.getElementById("cold_year");

	  citySelect.addEventListener("change", handleSelectChange);
	  yearSelect.addEventListener("change", handleSelectChange);
	});
function handleSelectChange() {
	  const localName = document.getElementById("city_detail").value;
	  const year = document.getElementById("year").value;

	  if (localName && year) {
	    loadWinterCorrelation(localName, year);
	  }
	}
//chart를 생성하기 전에 기존 차트가 있으면 파괴
function destroyIfChartExists(id) {
	const chartCanvas = Chart.getChart(id);
	if (chartCanvas) chartCanvas.destroy();
}

async function loadWinterCorrelation(localName, year) {
  try {
		const queryParams = new URLSearchParams({ localname: localName, year });
		
		const response = await fetch('http://localhost:8000/api/gas/coldDaySupply?'+queryParams);
    const data = await response.json();
    
    const labels = data.map(item => item.Month+'월');
    const coldDays = data.map(item => item.ColdDay);
    const gasSupply = data.map(item => item.GasSupply);
     
    destroyIfChartExists("coldDayChart");
    
    const ctx = document.getElementById("coldDayChart").getContext("2d");
    new Chart(ctx, {
    	  data: {
    	    labels: labels,
    	    datasets: [
    	      {
    	        type: 'line',
    	        label: "동계한파일수",
    	        data: coldDays,
    	        borderColor: "rgba(255, 99, 132, 1)",
    	        backgroundColor: "rgba(255, 99, 132, 0.1)",
    	        yAxisID: 'y1',
    	        tension: 0.3, // 부드러운 곡선
    	        pointStyle: 'circle',
    	        pointRadius: 6,
    	        pointBorderWidth: 2,
    	        pointBackgroundColor: '#fff',
    	        pointBorderColor: 'rgba(255, 99, 132, 1)',
    	        borderDash: [5, 5], // 점선 효과
    	        fill: false
    	      },  {
    	        type: 'line', // 혹은 'line' 으로 꺾은선 변경 가능
    	        label: "가스사용량",
    	        data: gasSupply,
    	        borderColor: "rgba(54, 162, 235,  1)",
    	        backgroundColor: "rgba(54, 162, 235, 0.1)",
    	        yAxisID: 'y2',
    	        tension: 0.3, // 부드러운 곡선
    	        pointStyle: 'circle',
    	        pointRadius: 6,
    	        pointBorderWidth: 2,
    	        pointBackgroundColor: '#fff',
    	        pointBorderColor: 'rgba(54, 162, 235, 1)',
    	       /*  borderDash: [5, 5], // 점선 효과 */
    	        fill: false
    	      }
    	      
    	     /*  {
    	        type: 'bar', // 혹은 'line' 으로 꺾은선 변경 가능
    	        label: "가스사용량",
    	        data: gasSupply,
    	        backgroundColor: "rgba(54, 162, 235, 0.5)",
    	        yAxisID: 'y2'
    	      } */
    	    ]
    	  },
    	  options: {
    	    responsive: true,
    	    plugins: {
    	      title: {
    	        display: true,
    	        text: "동계한파일수 vs 가스사용량"
    	      }
    	    },
    	    scales: {
    	      y1: {
    	        type: 'linear',
    	        position: 'left',
    	        title: { display: true, text: '동계한파일수' },
    	        beginAtZero: true
    	      
    	      },
    	      y2: {
    	        type: 'linear',
    	        position: 'right',
    	        title: { display: true, text: '가스사용량' },
    	        beginAtZero: true,
    	       /*  grid: { drawOnChartArea: false } */
    	      }
    	    }
    	  }
    	});


  } catch (error) {
    console.error("데이터 불러오기 실패:", error);
  }
}

// ✅ 호출 예시
//loadWinterCorrelation("강원특별자치도", 2020);
</script>

</body>

</html>