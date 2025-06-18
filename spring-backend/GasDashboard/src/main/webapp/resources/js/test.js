let gasChart;

async function fetchPrediction() {
  const selectedCity = document.getElementById("city").value || '서울특별시'; // 기본값 설정 가능
  const selectedModel = document.getElementById("model").value;
  const selectedPeriod = document.getElementById("period").value || 3; // 기본값 3개월
  
  if (!selectedCity) {
    alert("지역을 선택하세요.");
    return;
  }
  if (!selectedModel) {
    alert("분석 모델을 선택하세요.");
    return;
  }
  
	const loading = document.getElementById("loading");
	loading.style.display = "inline";
	
  try {
    let data;
    if (selectedModel === 'LSTM') {
      // LSTM 모델 호출
      const future_months = selectedPeriod;
      const recent_months = 15;
      const sequence_length = 12;

      const queryParams = new URLSearchParams({
        region: selectedCity,
        future_months,
        recent_months,
        sequence_length
      });

      const response = await fetch('http://localhost:8000/api/gas/lstm-prediction?' + queryParams);
      data = await response.json();

    } else if (selectedModel === 'XGBoost') {
      // XGBoost 모델 호출
      const baseDateStr = '2025-03-01';
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
        end_date: endDateStr
      });

      const response = await fetch('http://localhost:8000/api/gas/xgboost-prediction?' + queryParams);
      data = await response.json();

    }else if(selectedModel === 'Prophet'){
      // Prophet 모델 호출
      const future_predict_months = selectedPeriod;
      const recent_actual_months = 15;

      const queryParams = new URLSearchParams({
        local_name: selectedCity,
        future_predict_months,
        recent_actual_months
      });

      const response = await fetch('http://localhost:8000/api/gas/prophet-prediction?' + queryParams);
      data = await response.json();    
    }
    else {
      alert("지원하지 않는 모델입니다.");
      return;
    }

    const labels = Object.keys(data);
    const actual = labels.map(key => data[key].actual);
    const pastPred = labels.map(key => data[key].past_pred);
    const futurePred = labels.map(key => data[key].future_pred);

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
    alert("예측 데이터를 가져오는 중 에러 발생: " + error);
  }finally {
			loading.style.display = "none";
  }
}
