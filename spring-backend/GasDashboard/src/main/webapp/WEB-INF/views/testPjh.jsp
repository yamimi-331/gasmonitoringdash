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
    <option value="서울">서울특별시</option>
    <option value="인천">인천광역시</option>
    <option value="경기">경기도</option>
    <option value="부산">부산광역시</option>
    <option value="대구">대구광역시</option>
    <option value="광주">광주광역시</option>
    <option value="대전">대전광역시</option>
    <option value="울산">울산광역시</option>
    <option value="세종">세종특별자치시</option>
    <option value="강원">강원특별자치도</option>
    <option value="충북">충청북도</option>
    <option value="충남">충청남도</option>
    <option value="전북">전북특별자치도</option>
    <option value="전남">전라남도</option>
    <option value="경북">경상북도</option>
    <option value="경남">경상남도</option>
    <option value="제주">제주특별자치도</option>
  </select>
  <label for="model">분석 모델 선택:</label>
  <select id="model" name="model" required>
    <option value="" disabled selected>모델을 선택하세요</option>
    <option value="XGBoost">XGBoost</option>
    <option value="Prophet">Prophet</option>
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
	<p>선택된 모델: <span id="selectedModelText">없음</span></p>
	<p id="loading">데이터를 불러오는 중입니다...</p>
	<p id="errorMsg"></p>
	<img id="localChart" alt="차트 이미지" />
	<img id="modelChart" alt="차트 이미지" />


<script type="text/javascript">
function fetchPrediction() {
	const selectedCity = document.getElementById("city").value;
	const selectedModel = document.getElementById("model").value;
	const selectedCityText = document.getElementById("selectedCityText");
	const selectedModelText = document.getElementById("selectedModelText");
	const localImg = document.getElementById("localChart");
	const modelImg = document.getElementById("modelChart");
	const loading = document.getElementById("loading");
	const errorMsg = document.getElementById("errorMsg");

	errorMsg.textContent = "";
	localImg.style.display = "none";
	modelImg.style.display = "none";

	if (!selectedCity) {
		alert("지역을 선택하세요.");
		return;
	}
	if (!selectedModel) {
		alert("분석 모델을 선택하세요.");
		return;
	}

	// 로딩 표시
	loading.style.display = "inline";

	console.log("선택된 타입:", selectedCity);  // 디버깅용 로그
	console.log("선택된 모델:", selectedModel);

	const url = "http://localhost:8000/api/gas/local?city=" + encodeURIComponent(selectedCity) + "&model=" + encodeURIComponent(selectedModel);
	fetch(url)
		.then(response => {
			if (!response.ok) throw new Error("네트워크 응답이 올바르지 않습니다.");
			return response.json();
		})
		.then(data => {
			loading.style.display = "none";

		if (!data.localChartImage) {
			errorMsg.textContent = "지역 차트 이미지 데이터를 받지 못했습니다.";
			return;
		}
		if (!data.modelChartImage) {
			errorMsg.textContent = "모델 차트 이미지 데이터를 받지 못했습니다.";
			return;
		}

		selectedCityText.textContent = selectedCity;
		selectedModelText.textContent = selectedModel;
		
		localImg.src = "data:image/png;base64," + data.localChartImage;
		localImg.style.display = "block";
		modelImg.src = "data:image/png;base64," + data.modelChartImage;
	    modelImg.style.display = "block";
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