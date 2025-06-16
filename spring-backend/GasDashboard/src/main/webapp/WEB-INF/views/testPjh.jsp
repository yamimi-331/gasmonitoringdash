<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>

<form method="get" id="cityForm" onsubmit="return false;">
  <label for="city">지역 선택:</label>
  <select id="city" name="city" required>
    <option value="" disabled selected>지역을 선택하세요</option>
    <option value="서울">서울</option>
    <option value="경기도">경기도</option>
  </select>
  <button type="button" onclick="fetchPrediction()">조회</button>
</form>

<!-- <p>선택된 지역: ${selectedCity}</p>
<p>이미지 길이: ${chartImage.length()}</p>

	<c:if test="${not empty chartImage}">
		<h3>선택한 지역: ${selectedCity}</h3>
		<img src="data:image/png;base64,${chartImage}" alt="차트 이미지" />
	</c:if> -->
	
	<p>선택된 지역: <span id="selectedCityText">없음</span></p>
	<p id="loading">데이터를 불러오는 중입니다...</p>
	<p id="errorMsg"></p>
	<img id="chartImage" alt="차트 이미지" />


<script type="text/javascript">
function fetchPrediction() {
	 const select = document.getElementById("city");
	  const selectedCity = select.value;
	  const selectedCityText = document.getElementById("selectedCityText");
	  const img = document.getElementById("chartImage");
	  const loading = document.getElementById("loading");
	  const errorMsg = document.getElementById("errorMsg");

	  errorMsg.textContent = "";
	  img.style.display = "none";

	  if (!selectedCity) {
	    alert("지역을 선택하세요.");
	    return;
	  }

	  // 로딩 표시
	  loading.style.display = "inline";
	  
	  console.log("선택된 타입:", selectedCity);  // 디버깅용 로그

	  fetch('http://localhost:8000/api/gas/prediction?city=' + encodeURIComponent(selectedCity))
	    .then(response => {
	      if (!response.ok) throw new Error("네트워크 응답이 올바르지 않습니다.");
	      return response.json();
	    })
	    .then(data => {
	      loading.style.display = "none";

	      if (!data.chartImage) {
	        errorMsg.textContent = "이미지 데이터를 받지 못했습니다.";
	        return;
	      }

	      selectedCityText.textContent = selectedCity;
	      img.src = "data:image/png;base64," + data.chartImage;
	      img.style.display = "block";
	    })
	    .catch(err => {
	      loading.style.display = "none";
	      errorMsg.textContent = "에러 발생: " + err.message;
	      console.error(err);
	    });
	}
</script>
</body>
</html>