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
<div class="container">
		<div class="inner-container">
			<div class="head-box">
				<!-- 메인화면 글씨 -->
				<div class="title-container"><h2>마이 페이지</h2></div>
				<!-- 버튼 내비게이션 -->
				<div class="header-container">
					<!-- 위쪽 텍스트 -->
					<div class="header-inner-container">
						<span>${currentUserInfo.user_nm} 님, 환영합니다.</span> 
					</div>
					<!-- 아래쪽 버튼 -->
					<div class="header-inner-container">
						<button class="green-btn-2" onclick='location.href="/logout"'>로그아웃</button>
						<c:if test="${currentUserInfo.admin_yn.toString() eq 'Y'}">
							<button class="green-btn-2" onclick="location.href='/admin'">관리자 기능</button>
						</c:if>
					</div>
				</div>
			</div>
			<div class="green-line"></div>
			<div class="main-container">
				<!-- 내 정보 보기 버튼 (로그인 안 되어 있으면 로그인 페이지로 이동) -->
				<a class="page-tab-a" href="/simplelookup">▶ 간편 요금 조회</a> 
				<a class="page-tab-a" href="/">▶ 메인페이지</a> 
			</div>
			<div class="green-line"></div>
		</div>
		<div class="inner-container">
			<div class="select-box">
				<a href="/usage" class="box1">사용량</a>
				<a href="/charge" class="box2">요금</a>
			</div>
			<div class="data-box">
				<div class="title">이번 달 냉/난방 사용 현황</div>
				<div class="table-box">
					<table>
						<colgroup>
							<col width="50%">
							<col width="50%">
						</colgroup>
						<tr>
							<th>도시가스</th>
							<th>전기</th>
						</tr>
						<tr>
							<td>
								<c:choose>
							        <c:when test="${not empty gasUsage}">
							            ${gasUsage.gasUsageAmount} ㎥
							        </c:when>
							        <c:otherwise>
							            ${gasUsageMsg}
							        </c:otherwise>
							    </c:choose>
							</td>
							<td>
								<c:choose>
							        <c:when test="${not empty elecUsage}">
							            ${elecUsage.elecUsageAmount} kWh
							        </c:when>
							        <c:otherwise>
							            ${elecUsageMsg}
							        </c:otherwise>
							    </c:choose>
							</td>
						</tr>
					</table>
				</div>
				<div class="title">냉/난방 사용 이력</div>
				<div class="chart-box">
					<div class="chart-container">
						<canvas class="usageChart" id="monthChart"></canvas>
					</div>
				</div>
				<div class="title">냉/난방 사용 이력</div>
				<form method="get" action="/usage/period" onsubmit="return validateDates(this)" class="form-box">
					<div class="inner-form-box">
						<span>기간 : </span>
						<input type="date" name="startDate" id="startDate" value="${not empty param.startDate ? param.startDate : firstDayStr}" pattern="yyyy-MM-dd">
						 ~ <input type="date" name="endDate" id="endDate" value="${not empty param.endDate ? param.endDate : lastDayStr}" pattern="yyyy-MM-dd">
						<input type="submit" class="green-btn-2" value="조회">
					</div>
					<div>* 최대 24개월 분의 자료만 조회가 가능합니다.</div>
				</form>				
				<div class="table-box">
					<table>
						<caption class="text-bold">가스 사용 상세 내역</caption>
						<colgroup>
							<col width="25%">
							<col width="25%">
							<col width="25%">
							<col width="25%">
						</colgroup>
						<tr>
							<th>용도</th>
							<th>표준원가</th>
							<th>사용량</th>
							<th>날짜</th>
						</tr>
						<c:choose>
							<c:when test="${not empty gasUse}">
								<c:forEach var="item" items="${gasUse}">
									<tr>
										<td>${item.usageType}</td>
										<td>${item.unitCharge}</td>
										<td>${item.gas_usage} ㎥</td>
										<td><fmt:formatDate pattern="yyyy-MM-dd" value="${ item.gas_time }"/></td>
									</tr>
								</c:forEach>
							</c:when>
							<c:otherwise>
								<tr>
									<td colspan="4">${ gasUsageDetailMsg }</td>
								</tr>
							</c:otherwise>
						</c:choose>
					</table>
					<table>
						<caption class="text-bold">전기 사용 상세 내역</caption>
						<colgroup>
							<col width="25%">
							<col width="25%">
							<col width="25%">
							<col width="25%">
						</colgroup>
						<tr>
							<th>타입</th>
							<th>표준원가</th>
							<th>사용량</th>
							<th>날짜</th>
						</tr>
						<c:choose>
							<c:when test="${not empty elecUse}">
								<c:forEach var="item" items="${elecUse}">
									<tr>
										<td>${item.usageType}</td>
										<td>${item.unitCharge}</td>
										<td>${item.elec_usage} kWh</td>
										<td><fmt:formatDate pattern="yyyy-MM-dd" value="${ item.elec_time }"/></td>
									</tr>
								</c:forEach>
							</c:when>
							<c:otherwise>
								<tr>
									<td colspan="4">${ elecUsageDetailMsg }</td>
								</tr>
							</c:otherwise>
						</c:choose>
					</table>
				</div>
			</div>
		</div>
	</div>
		
	<!-- 여긴 높이 보정용 푸터 입니다. -->
	<footer></footer>
</body>
</html>