/**
 *
 */

// 가스차트를 담을 변수
let gasChart;
let yearLocalSupply, populationSupply, personalGasUse;

document.addEventListener("DOMContentLoaded", () => {
	const yearDropdown = document.getElementById("year");
	const cidyDropdown = document.getElementById("city_detail");
	//연도 변경시
	yearDropdown.addEventListener("change", () => {
		const selectedYear = yearDropdown.value;
		yearLocalGasChart(selectedYear);
	});
	//지역 변경시
	cidyDropdown.addEventListener("change", () => {
		const selectedCity = cidyDropdown.value;
		populationChartDraw(selectedCity);
	});
	// 초기 호출
	fetchPrediction();
	yearLocalGasChart("2025");
	populationChartDraw("서울특별시");
	});


//#region  차트생성함수
// 가스 공급량 및 수요예측 차트 생성 함수
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
  const loading = document.getElementById("loading");
  loading.style.display = "inline";

  try {
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

    if (gasChart) gasChart.destroy();
    // 차트 그리기
    const ctx = document.getElementById("gasChart").getContext("2d");
    gasChart = new Chart(ctx, {
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
        plugins: {
          title: {
            display: true,
            text: "가스 공급량 및 수요 예측",
            font: { size: 18 },
          },
          tooltip: {
            mode: "index",
            intersect: false,
          },
        },
        scales: {
          x: {
            title: { display: true, text: "월" },
          },
          y: {
            title: { display: true, text: "공급량" },
            beginAtZero: true,
          },
        },
      },
    });
  } catch (error) {
    alert("예측 데이터를 가져오는 중 에러 발생: " + error);
  } finally {
    // 로딩중 메세지 비활성화
    loading.style.display = "none";
  }
}

// 연도별 각 지역의 가스 공급량 막대 그래프
async function yearLocalGasChart(year) {
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

		if (yearLocalSupply) yearLocalSupply.destroy();

		const ctx = document.getElementById('yearLocalSupply').getContext('2d');
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
					text: year + '년, 지역별 가스 총 공급량',
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

// 평균 인구수,가스 총 공급량,1인당 가스 사용량 json 받아오기
// populationSupplyChart, personalGasUseChart 실행
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
		
		if (populationSupply) populationSupply.destroy();
		if (personalGasUse) personalGasUse.destroy();
		
		populationSupply = populationSupplyChart('populationSupply', years, populations, supplies, city)
		personalGasUse = personalGasUseChart('personalGasUse', years, perPerson, city)
		
	} catch (error) {
		alert("데이터 가져오기 오류: " + error);
	}finally {
		loading.style.display = "none";
	}
}

//인구수 및 가스 공급량 추이 복합 그래프
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
	return new Chart(ctx, {
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

//1인당 가스 사용량 꺾은선 그래프
function personalGasUseChart(canvasId, labels, data, city) {
	const ctx = document.getElementById(canvasId).getContext('2d');
	return new Chart(ctx, {
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

//#endregion