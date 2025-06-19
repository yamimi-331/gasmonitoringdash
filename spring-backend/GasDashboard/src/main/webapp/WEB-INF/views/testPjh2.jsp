<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<style>
#topLocalSupply{
	display:flex;
	flex-wrap:wrap;
	gap:20px;
	justify-content:center;
	width: 100%;
	height: 200px;
	margin: 0 auto;
}
#topLocalSupply canvas {
	max-width: 15%;
}
</style>
</head>
<body>
	<form method="get" id="cityForm" onsubmit="return false;">
		<label for="city_detail">지역 선택:</label>
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
	<div id="topLocalSupply"></div>
	<canvas id="yearLocalSupply"></canvas>
	<canvas id="populationSupply"></canvas>
	<canvas id="personalGasUse"></canvas>
	
<script>
document.addEventListener("DOMContentLoaded", () => {
	const yearDropdown = document.getElementById("year");
	const cidyDropdown = document.getElementById("city_detail");
	//연도 변경시
	yearDropdown.addEventListener("change", () => {
		const selectedYear = yearDropdown.value;
		yearLocalChartDraw(selectedYear);
	});
	//지역 변경시
	cidyDropdown.addEventListener("change", () => {
		const selectedCity = cidyDropdown.value;
		populationChartDraw(selectedCity);
	});
	// 초기 호출
	yearLocalChartDraw("2025");
	populationChartDraw("서울특별시");
	});

// 기존 차트 제거
function destroyIfChartExists(id) {
	const chartCanvas = Chart.getChart(id);
	if (chartCanvas) chartCanvas.destroy();
}

//연도별 각 지역의 가스 총 공급량 json 받아오기
//topLocalSupplyChart = "상위 5개 지역 가스 공급량 점유율 차트"
//yearLocalGasChart = "연도별 전국 가스 공급량 차트"
async function yearLocalChartDraw(year) {
	const loading = document.getElementById("loading");
	loading.style.display = "inline";
	
	try {
		const response = await fetch('http://localhost:8000/api/gas/yearsupply?year=' + year);
		data = await response.json();
		const yearData = data[year];
		
		// 기존 차트 파괴
		destroyIfChartExists("yearLocalSupply");

		// 새로 그리기 (반환값 필요 없음)
		topLocalSupplyChart(yearData, year);
		yearLocalGasChart('yearLocalSupply', yearData, year);
	} catch(error) {
		alert("데이터 가져오기 오류: " + error);
	} finally {
		loading.style.display = "none";
	}
}

// 각 지역의 그래프 색상 코드
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

//도넛 차트 가운데 텍스트 표시 플러그인
const donutCenterText = {
  id: 'donutCenterText',
  afterDraw(chart) {
    const { ctx, chartArea: { top, bottom, left, right, width, height } } = chart;
    ctx.save();

    const centerX = (left + right) / 2;
    const centerY = (top + bottom) / 2;

    const text = chart.options.plugins.donutCenterText?.text || '';
    const color = chart.options.plugins.donutCenterText?.color || '#000';

    ctx.fillStyle = color;
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';
    ctx.font = 'bold 18px Arial';
    ctx.fillText(text, centerX, centerY);

    ctx.restore();
  }
};

// "상위 5개 지역 가스 공급량 점유율 차트"
function topLocalSupplyChart(yearData, year){
	const container = document.getElementById('topLocalSupply');
	container.innerHTML = ""; // 기존 차트 제거
	
	//상위 5개 도시 추출
	const entries = Object.entries(yearData);
	const top5 = entries.slice(0, 5);
	//전체 공급량 총 합 계산
	const totalSupply = Object.values(yearData).reduce((sum, val) => sum + val, 0);
	
	//top5차트 도넛형으로 생성
	top5.forEach(([city, supply], index) => {
		const canvasId = `donutChart${index}`;
		const canvas = document.createElement("canvas");
		canvas.id = canvasId;
		canvas.style.width = "15%"
		canvas.style.height = "120px";
		canvas.style.flex = "0 0 auto"
		container.appendChild(canvas);

		const ctx = canvas.getContext("2d");
		const percentage = ((supply / totalSupply) * 100).toFixed(1) + "%";
		new Chart(ctx, {
			type: 'doughnut',
			data: {
				datasets: [{
					data: [supply, totalSupply - supply],
					backgroundColor: [
						regionColors[city] || "rgba(75, 192, 192, 0.7)",
						"rgba(200, 200, 200, 0.3)"
					]
				}]
			},
			options: {
				plugins: {
					responsive: true,
					aspectRatio: 1,
					title: {
						display: true,
						text: city+ '의 공급량 점유율'
					},
                    donutCenterText: {
                        text: percentage,
                        color: "#333"
                    }
				}
			},
			plugins: [donutCenterText]
		});
	});
}

//"연도별 전국 가스 공급량 차트"
function yearLocalGasChart(canvasId, yearData, year) {
	const labels = Object.keys(yearData);
	const supplyValues = Object.values(yearData);

	const backgroundColors = labels.map(label => regionColors[label] || 'rgba(200,200,200,0.7)');

	const ctx = document.getElementById(canvasId).getContext('2d');
	yearLocalSupply = new Chart(ctx, {
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
				text: year+ '년 지역별 가스 총 공급량',
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
}

//평균 인구수,가스 총 공급량,1인당 가스 사용량 json 받아오기
//populationSupplyChart = "지역/년도별 인구수 및 가스 공급량 차트"
//personalGasUseChart = "지역별 1인당 가스 사용량 차트"
async function populationChartDraw(city) {
	const loading = document.getElementById("loading");
	loading.style.display = "inline";
	
	try {
		const response = await fetch('http://localhost:8000/api/gas/populationsupply?localname=' + city);
		data = await response.json();

		const cityData = data[city];
		const years = Object.keys(cityData);
		const populations = years.map(y => cityData[y]["평균 인구수"]);
		const supplies = years.map(y => cityData[y]["가스 총 공급량"]);
		const perPerson = years.map(y => cityData[y]["1인당 가스 사용량"]);
		
		// 기존 차트 파괴
		destroyIfChartExists("populationSupply");
		destroyIfChartExists("personalGasUse");

		// 새로 그리기 (반환값 필요 없음)
		populationSupplyChart('populationSupply', years, populations, supplies, city)
		personalGasUseChart('personalGasUse', years, perPerson, city)
		
	} catch (error) {
		alert("데이터 가져오기 오류: " + error);
	}finally {
		loading.style.display = "none";
	}
}

//"지역/년도별 인구수 및 가스 공급량 차트"
function populationSupplyChart(canvasId, labels, populations, supplies, city){
	// 최대, 최소값 계산
    const maxPop = Math.max(...populations);
    const minPop = Math.min(...populations);
    
    // 여유값 계산 (최대 - 최소의 20%)
    const popMargin = Math.ceil((maxPop - minPop) * 0.3);

    // 최소, 최대값에 margin 적용 (음수가 되지 않도록 Math.max(0, ...) 처리)
    const y1Min = Math.max(0, minPop - popMargin);
    const y1Max = maxPop + popMargin;
	
	const ctx = document.getElementById(canvasId).getContext('2d');
	new Chart(ctx, {
		type: 'bar',
		data: {
			labels: labels,
			datasets: [
				{
					type: 'line',
					label: '평균 인구수',
					data: populations,
					borderColor: 'rgba(54, 162, 235, 0.8)',
					backgroundColor: 'rgba(54, 162, 235, 0.2)',
					yAxisID: 'y1',
					tension: 0.3,
					fill: false
				},
				{
					type: 'bar',
					label: '총 공급량',
					data: supplies,
					backgroundColor: 'rgba(255, 99, 132, 0.6)',
					yAxisID: 'y2',
				}
			]
		},
		options: {
			responsive: true,
			plugins: {
				title: {
					display: true,
					text: city + '의 연도별 인구수 및 가스공급량'
				}
			},
			scales: {
				y1: {
					type: 'linear',
					position: 'left',
					min: y1Min,
                    max: y1Max,
					title: {
						display: true,
						text: '평균 인구수'
					}
				},
				y2: {
					type: 'linear',
					position: 'right',
					title: {
						display: true,
						text: '총 공급량 (m³)'
					},
					grid: {
						drawOnChartArea: false
					}
				}
			}
		}
	});
}

//"지역별 1인당 가스 사용량 차트"
function personalGasUseChart(canvasId, labels, data, city) {
	const maxY = Math.max(...data);
	
	const ctx = document.getElementById(canvasId).getContext('2d');
	new Chart(ctx, {
		type: 'line',
		data: {
			labels: labels,
			datasets: [{
				label: '1인당 가스 사용량 (m³)',
				data: data,
				borderColor: 'rgba(75, 192, 192, 0.8)',
				backgroundColor: 'rgba(75, 192, 192, 0.2)',
				tension: 0.3,
				fill: true
			}]
		},
		options: {
			responsive: true,
			plugins: {
				title: {
					display: true,
					text: city + '의 연도별 1인당 가스 사용량'
				}
			},
			scales: {
				y: {
					beginAtZero: true,
					title: {
						display: true,
						text: '1인당 가스 사용량 (m³)'
					}
				}
			}
		}
	});
}
</script>
</body>
</html>