/**
 *
 */

// 가스차트를 담을 변수
let gasChart;

// 가스 공급량 및 수요예측 차트 생성 함수
async function fetchPrediction() {
  const selectedCity = document.getElementById("city").value; // 지역
  const selectedModel = document.getElementById("model").value; // 예측모델
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
