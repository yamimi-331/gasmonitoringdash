/**
 *
 */
// 전역변수

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


// 돔 로드시
document.addEventListener("DOMContentLoaded", () => {
	const yearDropdown = document.getElementById("year");
	const cidyDropdown = document.getElementById("city_detail");
	// 한파 차트용 변수
	const citySelect = document.getElementById("cold_city");
	const yearSelect = document.getElementById("cold_year");

	// 한파 년도/지역 변경시
	citySelect.addEventListener("change", handleSelectChange);
	yearSelect.addEventListener("change", handleSelectChange);
	
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
	fetchPrediction();
	yearLocalChartDraw("2025");
	populationChartDraw("서울특별시");
	loadWinterCorrelation("서울특별시","2025");
});

//#region  차트생성함수
// "가스 공급량 및 수요예측 차트" 생성 함수
async function fetchPrediction() {
  const selectedCity = document.getElementById("city").value || "서울특별시"; // 지역
  const selectedModel = document.getElementById("model").value || "XGBoost"; // 예측모델
  const selectedPeriod = document.getElementById("period").value || 3; // 기본값 3개월

  // 지역 밸리데이션
  if (!selectedCity) {
    alert("지역을 선택하세요.");
    return;
  }
  // 모델 밸리데이션
  if (!selectedModel) {
    alert("분석 모델을 선택하세요.");
    return;
  }

  // 로딩중 텍스트 활성화
  //const loading = document.getElementById("loading");
  //loading.style.display = "inline";

  try { 
	  // 로딩창 표시
	  showLoading('gasChart');
	  
	  // 브라우저에 렌더링 타이밍을 줌
	  await new Promise(resolve => setTimeout(resolve, 50));
    // 차트용 데이터
    let data;
    // 평가점수 데이터
    let rmse;
    let mae;
    let mape;

    if (selectedModel === "LSTM") {
      // LSTM 모델 호출
      const future_months = selectedPeriod;
      const recent_months = 15;
      const sequence_length = 12;

      const queryParams = new URLSearchParams({
        local_name: selectedCity,
        future_months,
        recent_months,
        sequence_length,
      });
      // FastAPI 요청
      const response = await fetch(
        "http://localhost:8000/api/gas/lstm-prediction?" + queryParams
      );
      data = await response.json();
    } else if (selectedModel === "XGBoost") {
      // XGBoost 모델 호출
      const baseDateStr = "2025-03-01";
      const baseDate = new Date(baseDateStr);

      const startDate = new Date(baseDate.getFullYear() - 1, 0, 1);
      const startDateStr = startDate.toISOString().slice(0, 10);

      const period = Number(selectedPeriod);
      const endDate = new Date(baseDate);
      endDate.setMonth(endDate.getMonth() + period);
      const endDateStr = endDate.toISOString().slice(0, 10);

      const queryParams = new URLSearchParams({
        local_name: selectedCity,
        start_date: startDateStr,
        end_date: endDateStr,
      });
      // FastAPI 요청
      const response = await fetch(
        "http://localhost:8000/api/gas/xgboost-prediction?" + queryParams
      );
      data = await response.json();
    } else if (selectedModel === "Prophet") {
      // Prophet 모델 호출
      const future_predict_months = selectedPeriod;
      const recent_actual_months = 15;

      const queryParams = new URLSearchParams({
        local_name: selectedCity,
        future_predict_months,
        recent_actual_months,
      });
      // FastAPI 요청
      const response = await fetch(
        "http://localhost:8000/api/gas/prophet-prediction?" + queryParams
      );
      data = await response.json();
    } else {
      alert("지원하지 않는 모델입니다.");
      return;
    }

    // 예측 결과 데이터
    const predictionResult = data.prediction_result || {};

    const labels = Object.keys(predictionResult);
    const actual = labels.map((key) => predictionResult[key].actual);   // 실제 값
    const pastPred = labels.map((key) => predictionResult[key].past_pred);// 과거 데이터 예측값
    const futurePred = labels.map((key) => predictionResult[key].future_pred);// 미래 예측값

    // 평가점수
    rmse = data.evaluation?.RMSE || null;
    mae = data.evaluation?.MAE || null;
    mape = data.evaluation?.["MAPE (%)"] || null;
    console.log("평가 점수:", { rmse, mae, mape });

	// 차트가 존재하면 제거후 생성
	destroyIfChartExists("gasChart");

	// 차트 그리기
    const ctx = document.getElementById("gasChart").getContext("2d");
    new Chart(ctx, {
      type: "bar",
      data: {
        labels: labels,
        datasets: [
          {
            label: "실제 공급량",
            data: actual,
            backgroundColor: "rgba(54, 162, 235, 0.7)",
          },
          {
            label: "과거 예측",
            data: pastPred,
            backgroundColor: "rgba(255, 206, 86, 0.7)",
          },
          {
            label: "미래 예측",
            data: futurePred,
            backgroundColor: "rgba(75, 192, 192, 0.7)",
          },
        ],
      },
      options: {
        responsive: true,
         maintainAspectRatio: false,
        plugins: {
          title: {
            display: true,
            text: selectedCity+"의 가스 공급량 및 수요 예측 ("+selectedModel+")",
            font: { size: 24 },
          },
          tooltip: {
            mode: "index",
            intersect: false,
          },
        },
        scales: {
          x: {
            ticks: {font: { size: 15 } },
          },
          y: {
            title: { display: true, text: "공급량 (백만 m³)" , font: { size: 15 }},
			ticks:{
				callback: function(value){
					return (value / 1000000).toFixed(0)
				}
			},
            beginAtZero: true,
          },
        },
      },
    });
  } catch (error) {
    alert("예측 데이터를 가져오는 중 에러 발생: " + error);
  } finally {
    // 로딩중 메세지 비활성화
    //loading.style.display = "none";
     requestAnimationFrame(() => {
	    hideLoading('gasChart');
	  });
  }
  
}

//연도별 각 지역의 가스 총 공급량 json 받아오기
//topLocalSupplyChart = "상위 5개 지역 가스 공급량 점유율 차트"
//yearLocalGasChart = "연도별 전국 가스 공급량 차트"
async function yearLocalChartDraw(year) {
	try {
		const response = await fetch('http://localhost:8000/api/gas/yearsupply?year=' + year);
		data = await response.json();
		const yearData = data[year];
		
		// 기존 차트 파괴
		destroyIfChartExists("yearLocalSupply");
		
		// 새로 그리기 (반환값 필요 없음)
		await topLocalSupplyChart(yearData, year);
		await yearLocalGasChart('yearLocalSupply', yearData, year);
	} catch(error) {
		alert("데이터 가져오기 오류: " + error);
	} finally {
	}
}

// "상위 5개 지역 가스 공급량 점유율 차트"
async function topLocalSupplyChart(yearData, year){
	showLoading('topLocalSupply');
	// 브라우저에 렌더링 타이밍을 줌
	await new Promise(resolve => setTimeout(resolve, 50));

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
		canvas.classList.add("donut-chart");
		canvas.width = 160;
		canvas.height = 160;
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
				responsive: false,
  				maintainAspectRatio: true,
				aspectRatio: 1,
				plugins: {
					title: {
						display: true,
						text: city+ '의 공급량 점유율',
						font: { size: 15 }
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
	requestAnimationFrame(() => {
	    hideLoading('topLocalSupply');
    });
}

// "연도별 전국 가스 공급량 차트"
async function yearLocalGasChart(canvasId, yearData, year) {
	showLoading('yearLocalSupply');	
	// 브라우저에 렌더링 타이밍을 줌
	await new Promise(resolve => setTimeout(resolve, 50));
		
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
			maintainAspectRatio: false,
			plugins: {
				title: {
				display: true,
				text: year+ '년 전국 가스 총 공급량',
				font: { size: 24 }
				},
				tooltip: {
				mode: 'index',
				intersect: false
				}
			},
			scales: {
				x: {
					ticks: { font: { size: 15 }}
				},
				y: {
					title: { display: true, text: '총 공급량(백만 m³)' , font: { size: 15 }},
					ticks:{
						callback: function(value){
							return (value / 1000000).toFixed(0)
						}
					},
					beginAtZero: true
				}
			}
		}
	});
	requestAnimationFrame(() => {
	    hideLoading('yearLocalSupply');
    });
}


// 평균 인구수,가스 총 공급량,1인당 가스 사용량 json 받아오기
// populationSupplyChart = "지역/년도별 인구수 및 가스 공급량 차트"
// personalGasUseChart = "지역별 1인당 가스 사용량 차트"
async function populationChartDraw(city) {
	
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
		await populationSupplyChart('populationSupply', years, populations, supplies, city)
		await personalGasUseChart('personalGasUse', years, perPerson, city)
		
	} catch (error) {
		alert("데이터 가져오기 오류: " + error);
	}finally {
		
	}
}

// chart를 생성하기 전에 기존 차트가 있으면 파괴
function destroyIfChartExists(id) {
	const chartCanvas = Chart.getChart(id);
	if (chartCanvas) chartCanvas.destroy();
}

// "지역/년도별 인구수 및 가스 공급량 차트"
async function populationSupplyChart(canvasId, labels, populations, supplies, city){
	showLoading('populationSupply');
	// 브라우저에 렌더링 타이밍을 줌
	await new Promise(resolve => setTimeout(resolve, 50));
	  
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
					position: 'right',
					min: y1Min,
                    max: y1Max,
					title: {
						display: true,
						text: '평균 인구수 (천 명)'
					},
					ticks:{
						callback: function(value){
							return (value / 1000).toFixed(0)
						}
					},
					grid: {
						drawOnChartArea: false
					}
				},
				y2: {
					type: 'linear',
					position: 'left',
					title: {
						display: true,
						text: '총 공급량 (백만 m³)'
					},
					ticks:{
						callback: function(value){
							return (value / 1000000).toFixed(0)
						}
					}
				}
			}
		}
	});
	requestAnimationFrame(() => {
	    	hideLoading('populationSupply');
	  	});
}

// "지역별 1인당 가스 사용량 차트"
async function personalGasUseChart(canvasId, labels, data, city) {
	showLoading('personalGasUse');
	// 브라우저에 렌더링 타이밍을 줌
	await new Promise(resolve => setTimeout(resolve, 50));
	  
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
	
	requestAnimationFrame(() => {
	    hideLoading('personalGasUse');
	});
}

// 선택 밸류 확인
function handleSelectChange() {
	const localName = document.getElementById("cold_city").value;
	const year = document.getElementById("cold_year").value;

	if (localName && year) {
		loadWinterCorrelation(localName, year);
	}
}

// "한파 일수 & 공급량 차트" and "온도 & 공급량 차트" 
async function loadWinterCorrelation(localName, year) {
  try {
	showLoading('coldDayChart');
	showLoading('temperatureChart');
	// 브라우저에 렌더링 타이밍을 줌
    await new Promise(resolve => setTimeout(resolve, 50));
	
	const queryParams = new URLSearchParams({ localname: localName, year });
		
	const response = await fetch('http://localhost:8000/api/gas/coldDayTempSupply?'+queryParams);
    const data = await response.json();
    
    const labels = data.map(item => item.YearMonth);
    const coldDays = data.map(item => item.ColdDay);
    const gasSupply = data.map(item => item.GasSupply);
    const temperatures = data.map(item => item.Temperature);
     
    destroyIfChartExists("coldDayChart");
    destroyIfChartExists("temperatureChart");
    
    const ctx1 = document.getElementById("coldDayChart").getContext("2d");
    new Chart(ctx1, {
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
    	        fill: false
    	      }
    	    ]
    	  },
    	  options: {
    	    responsive: true,
    	    plugins: {
    	      title: {
    	        display: true,
    	        text: localName+"의 "+ year + "년 동계 한파 일 수 & 가스 사용량 차트"
    	      }
    	    },
    	    scales: {
    	      y1: {
    	        type: 'linear',
    	        position: 'right',
    	        title: { display: true, text: '동계한파일수' },
				ticks:{
					precision:0,
					stepSize: 1
				},
				grid:{
					drawOnChartArea: false
				},
    	        beginAtZero: true
    	      },
    	      y2: {
    	        type: 'linear',
    	        position: 'left',
    	        title: { display: true, text: '가스사용량 (백만 m³)' },
				ticks:{
					callback: function(value){
						return (value / 1000000).toFixed(0)
					}
				},
    	        beginAtZero: true
    	      }
    	    }
    	  }
    	});
    	// 온도 차트 
	    const ctx2 = document.getElementById("temperatureChart").getContext("2d");
	    new Chart(ctx2, {
	      data: {
	        labels: labels,
	        datasets: [
	          {
	            type: 'line',
	            label: "기온 (°C)",
	            data: temperatures,
	            borderColor: "rgba(255, 159, 64, 1)",
	            backgroundColor: "rgba(255, 159, 64, 0.1)",
	            yAxisID: 'y1',
	            tension: 0.3,
	            pointStyle: 'circle',
	            pointRadius: 6,
	            pointBorderWidth: 2,
	            pointBackgroundColor: '#fff',
	            pointBorderColor: 'rgba(255, 159, 64, 1)',
	            fill: false
	          },
	          {
	            type: 'line',
	            label: "가스사용량",
	            data: gasSupply,
	            borderColor: "rgba(54, 162, 235, 1)",
	            backgroundColor: "rgba(54, 162, 235, 0.1)",
	            yAxisID: 'y2',
	            tension: 0.3,
	            pointStyle: 'circle',
	            pointRadius: 6,
	            pointBorderWidth: 2,
	            pointBackgroundColor: '#fff',
	            pointBorderColor: 'rgba(54, 162, 235, 1)',
	            fill: false
	          }
	        ]
	      },
	      options: {
	        responsive: true,
	        plugins: {
	          title: {
	            display: true,
	            text: `${localName}의 ${year}년 기온 & 가스 사용량 차트`
	          }
	        },
	        scales: {
	          y1: {
	            type: 'linear',
	            position: 'right',
	            title: { display: true, text: '기온 (°C)' },
	            grid: { drawOnChartArea: false },
	            beginAtZero: false
	          },
	          y2: {
	            type: 'linear',
	            position: 'left',
	            title: { display: true, text: '가스사용량 (백만 m³)' },
	            ticks: {
	              callback: function (value) {
	                return (value / 1000000).toFixed(0)
	              }
	            },
	            beginAtZero: true
	          }
	        }
	      }
	    });
    	
  } catch (error) {
    console.error("데이터 불러오기 실패:", error);
  } finally{
  	requestAnimationFrame(() => {
	    hideLoading('coldDayChart');
	     hideLoading('temperatureChart');
	  });
  }
}

// 스크롤 및 버튼으로 슬라이드 이동
document.addEventListener('DOMContentLoaded', () => {
  const scrollWrapper = document.querySelector('.dashboard-scroll-wrapper');
  const slides = document.querySelectorAll('.dashboard-page');
  let currentSlide = 0;
  let isScrolling = false;

  function scrollToSlide(index) {
    if (index < 0 || index >= slides.length) return;
    isScrolling = true;
    slides[index].scrollIntoView({ behavior: 'smooth', block: 'nearest', inline: 'start' });
    currentSlide = index;
    setTimeout(() => {
      isScrolling = false;
    }, 600);
  }

  scrollWrapper.addEventListener('wheel', e => {
    if (isScrolling) return;
    e.preventDefault();
    if (e.deltaY > 0) {
      // 아래로 휠 내림 → 다음 슬라이드로
      scrollToSlide(currentSlide + 1);
    } else if (e.deltaY < 0) {
      // 위로 휠 올림 → 이전 슬라이드로
      scrollToSlide(currentSlide - 1);
    }
  }, { passive: false });
  
  document.getElementById('prevBtn').addEventListener('click', () => {
    scrollToSlide(currentSlide - 1);
  });

  document.getElementById('nextBtn').addEventListener('click', () => {
    scrollToSlide(currentSlide + 1);
  });
});

// 로딩 기능 추가
function showLoading(canvasId) {
  const overlay = document.getElementById(`loading-${canvasId}`);
  if (overlay) overlay.style.display = 'flex';
}

function hideLoading(canvasId) {
  const overlay = document.getElementById(`loading-${canvasId}`);
  if (overlay) overlay.style.display = 'none';
}

//#endregion