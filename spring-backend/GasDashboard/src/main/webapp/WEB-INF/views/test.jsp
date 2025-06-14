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
	</c:if>

	<c:if test="${not empty error}">
		<p style="color: red;">오류: ${error}</p>
	</c:if>

</body>
</html>