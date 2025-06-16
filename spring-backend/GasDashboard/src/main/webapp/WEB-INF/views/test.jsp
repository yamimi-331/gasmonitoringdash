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

	<c:if test="${not empty models}">
		<h3>XGBoost</h3>
		<ul>
			<li>MSE: ${models.XGBoost.mse}</li>
			<li>RMSE: ${models.XGBoost.rmse}</li>
			<li>R²: ${models.XGBoost.r2}</li>
		</ul>

		<h3>Prophet</h3>
		<p>${models.Prophet.model}</p>

		<h3>LSTM</h3>
		<p>${models.LSTM.model}</p>
	</c:if>


	<h2>시각화 결과</h2>
	<c:if test="${not empty visualizations}">
		<h3>월별 추이</h3>
		<img src="data:image/png;base64,${visualizations.monthly_trend}" />

		<h3>온도-공급량 관계</h3>
		<img src="data:image/png;base64,${visualizations.temp_supply}" />

		<h3>지역별 패턴</h3>
		<img src="data:image/png;base64,${visualizations.regional_pattern}" />

		<h3>예측 비교</h3>
		<img
			src="data:image/png;base64,${visualizations.prediction_comparison}" />
		
		<h3>예측 비교2</h3>
		<img
			src="data:image/png;base64,${visualizations.supply_prediction_timeline}" />
	</c:if>

	<c:if test="${not empty error}">
		<p style="color: red;">오류: ${error}</p>
	</c:if>
	
	 <h1>2025년 지역별 가스 공급량 그래프</h1>

    <c:if test="${not empty error}">
        <p class="error">오류: ${error}</p>
    </c:if>

    <c:if test="${not empty message}">
        <p class="message">메시지: ${message}</p>
    </c:if>

    <c:if test="${not empty base64Image2025}">
        <%-- base64 인코딩된 이미지 문자열을 직접 사용합니다. --%>
        <img src="data:image/png;base64,${base64Image2025}" alt="2025 Regional Gas Supply Bar Chart">
    </c:if>
    <c:if test="${empty base64Image2025 && empty error}">
        <p>그래프 이미지를 불러올 수 없습니다. FastAPI 서버를 확인해주세요.</p>
    </c:if>
</body>
</html>