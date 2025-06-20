// gasUsageChart.js
// JSP에서 선언된 전역 변수 recentUsageData, localUsageData 를 사용

// recentUsageData가 배열 형태여야 함
const recentLabels = recentUsageData.map(item => item.date);
const recentData = recentUsageData.map(item => item.amount);

const recentUsageCtx = document.getElementById('recentUsageChart').getContext('2d');
new Chart(recentUsageCtx, {
  type: 'bar',
  data: {
    labels: recentLabels,
    datasets: [{
      label: '최근 12개월 가스 사용량',
      data: recentData,
      backgroundColor: 'rgba(75, 192, 192, 0.6)',
      borderColor: 'rgba(75, 192, 192, 1)',
      borderWidth: 1,
      barPercentage: 0.6
    }]
  },
  options: {
    responsive: true,
    plugins: {
      title: {
        display: true,
        text: '최근 12개월 월별 가스 사용량'
      },
      legend: {
        display: false
      },
      datalabels: {
        anchor: 'end',
        align: 'end',
        formatter: Math.round,
        color: '#333',
        font: { weight: 'bold' }
      }
    },
    scales: {
      y: {
        beginAtZero: true,
        title: { display: true, text: '사용량 (단위: m³)' }
      },
      x: {
        title: { display: true, text: '사용월' }
      }
    }
  }
});

// 두 번째 차트
const comparisonCtx = document.getElementById('localUsageComparison').getContext('2d');
new Chart(comparisonCtx, {
  type: 'bar',
  data: {
    labels: ['지역 평균', '나의 당월 사용량', '전년도 동월', '연간 평균'],
    datasets: [{
      label: '사용량 (단위: m³)',
      data: [
        localUsageData.avgCurrentMonthUsage,
        localUsageData.currentMonthUsage,
        localUsageData.lastYearSameMonthUsage,
        localUsageData.yearlyAvgUsage
      ],
      backgroundColor: [
        'rgba(54, 162, 235, 0.6)',
        'rgba(255, 99, 132, 0.6)',
        'rgba(255, 206, 86, 0.6)',
        'rgba(75, 192, 192, 0.6)'
      ],
      borderColor: [
        'rgba(54, 162, 235, 1)',
        'rgba(255, 99, 132, 1)',
        'rgba(255, 206, 86, 1)',
        'rgba(75, 192, 192, 1)'
      ],
      borderWidth: 1,
      barPercentage: 0.4
    }]
  },
  options: {
    responsive: true,
    layout: { padding: { top: 20 } },
    plugins: {
      title: { display: true, text: '내 사용량 vs 지역 평균 비교' },
      legend: { display: false },
      datalabels: {
        anchor: 'end',
        align: 'end',
        formatter: Math.round,
        color: '#000',
        font: { weight: 'bold' }
      }
    },
    scales: {
      y: {
        beginAtZero: true,
        suggestedMax: Math.max(
          localUsageData.avgCurrentMonthUsage,
          localUsageData.currentMonthUsage,
          localUsageData.lastYearSameMonthUsage,
          localUsageData.yearlyAvgUsage
        ) * 1.2,
        title: { display: true, text: '사용량 (m³)' }
      }
    }
  },
  plugins: [ChartDataLabels]
});
