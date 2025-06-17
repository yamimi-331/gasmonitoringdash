 let gasChart;

    async function fetchPrediction() {
      const region = '서울특별시';
      const future_months = 3;
      const recent_months = 6;
      const sequence_length = 12;

      const queryParams = new URLSearchParams({
        region,
        future_months,
        recent_months,
        sequence_length
      });

	try{
	    const response = await fetch('http://localhost:8000/api/gas/lstm-prediction?' + queryParams);
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
        alert("LSTM 예측 데이터를 가져오는 중 에러 발생: " + error);
      }
    }

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
        const response = await fetch('http://localhost:8000/api/gas/xgboost-prediction?' + queryParams);
        const contentType = response.headers.get("content-type");

        if (contentType && contentType.includes("application/json")) {
          const data = await response.json();
          document.getElementById("xgb-result").textContent = JSON.stringify(data, null, 2);
        } else {
          const text = await response.text();
          document.getElementById("xgb-result").textContent = "HTML 또는 잘못된 응답: \n" + text;
        }
      } catch (error) {
        document.getElementById("xgb-result").textContent = "에러 발생: " + error;
      }
    }