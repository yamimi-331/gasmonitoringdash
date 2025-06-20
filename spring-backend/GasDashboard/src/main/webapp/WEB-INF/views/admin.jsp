<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Eco</title>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="/resources/js/adminUsage.js"></script>
<script>
	const isLoggedIn = ${not empty sessionScope.currentUserInfo};
</script>
</head>
<body>
	<div class="container">
		<div class="inner-container">
			<div class="head-box">
				<!-- 아이콘 -->
				<a href="/"><img src="/resources/img/icon2.png" class="icon"></a>
				<!-- 메인화면 글씨 -->
				<div class="title-container">
					<h2>관리자 페이지</h2>
				</div>
				<!-- 버튼 내비게이션 -->
				<div class="header-container">
					<!-- 위쪽 텍스트 -->
					<div class="header-inner-container">
						<span>${currentUserInfo.user_nm} 님, 환영합니다.</span>
					</div>
					<!-- 아래쪽 버튼 -->
					<div class="header-inner-container">
						<button class="green-btn-2"
							onclick='location.href="/login/logout"'>로그아웃</button>
					</div>
				</div>
			</div>
			<div class="main-container">
				<!-- 페이지 이동 버튼 -->
				<a class="page-tab-a" href="/">▶ 메인페이지</a>
			</div>
		</div>

		<!-- 사용자 검색 영역 start------------------------------ -->
		<div class="inner-container">
			<div class="search-container">
				<h2>사용자 검색</h2>
				<div class="search-inner-container">
					<div class="search-area">
						<input type="text" id="searchKeyword" placeholder="사용자명 입력" autocomplete="off" />
						<button class="green-btn" onclick="searchUser()">검색</button>
					</div>
					<table id="userTable">
						<thead>
							<tr>
								<th style="width: 25%">아이디</th>
								<th style="width: 25%">이름</th>
								<th style="width: 25%">지역</th>
								<th style="width: 25%">상세주소</th>
							</tr>
						</thead>
						<tbody>
							<tr>
								<td colspan="4">조회된 사용자가 없습니다.</td>
							</tr>
						</tbody>
					</table>
				</div>

			</div>
		</div>
		<!-- 사용자 검색 영역 end------------------------------ -->

		<!-- 사용자별 에너지 사용량 관리 영역 start ------------------------ -->
		<div class="inner-container">
			<!-- 에너지 타입 선택 -->
			<div class="type-tab">
				<button id="gasBtn" class="type-tab-btn active"
					onclick="selectEnergyType('GAS')">가스 사용량</button>
				<button id="elecBtn" class="type-tab-btn"
					onclick="selectEnergyType('ELEC')">전기 사용량</button>
			</div>

			<div id="usageSection" class="result-container">
				<div class="search-area">
					<h3 id="usageTitle">가스 사용내역</h3>
					<button class="green-btn-admin" onclick="showUsageModal('add')">등록</button>
					<button class="green-btn-admin" onclick="showUsageModal('edit')">수정</button>
					<button class="green-btn-admin" onclick="deleteUsage()">삭제</button>
				</div>
				<div class="result-inner-container">
					<table id="usageTable" border="1">
						<thead>
							<tr>
								<th style="width: 20%;">선택</th>
								<th style="width: 40%;">날짜</th>
								<th style="width: 40%;">사용량</th>
							</tr>
						</thead>
						<tbody>
							<tr><td colspan="3">조회된 사용량 데이터가 없습니다.</td></tr>
						</tbody>
					</table>
					
				</div>
	
			</div>
		</div>			 
		<!-- 사용자별 에너지 사용량 관리 영역 end ------------------------ -->
		<!-- 등록 수정 모달 폼 전체 영역 -->
		<div id="usageModal" class="modal-container">
				<h3 id="modalTitle">사용량 관리</h3>
				<input type="hidden" id="modal_mode"> <input type="hidden"
					id="modal_usage_cd"> <input type="hidden"
					id="modal_user_id">
				<div class="modal-field">
					<fieldset>
						<legend>사용 일자:</legend>
						<select id="modal_year" name="modal_year">
							<option value="">-- 연도 선택 --</option>
							<option value="2020">2020년</option>
							<option value="2021">2021년</option>
							<option value="2022">2022년</option>
							<option value="2023">2023년</option>
							<option value="2024">2024년</option>
							<option value="2025">2025년</option>
						</select>
						<select id="modal_month" name="modal_month">
							<option value="">-- 월 선택 --</option>
							<option value="01">1월</option>
							<option value="02">2월</option>
							<option value="03">3월</option>
							<option value="04">4월</option>
							<option value="05">5월</option>
							<option value="06">6월</option>
							<option value="07">7월</option>
							<option value="08">8월</option>
							<option value="09">9월</option>
							<option value="10">10월</option>
							<option value="11">11월</option>
							<option value="12">12월</option>
						</select>
					</fieldset>
				</div>


				<div class="modal-field" style="margin-bottom: 20px;">
					<label for="modal_usage_input">사용량:</label>
					<input type="number" id="modal_usage_input" step="0.01" min="0" class="modal-input" required>
				</div>

				<div class="modal-buttons">
					<button class="green-btn-2" onclick="saveUsageData()">저장</button>
					<button class="green-btn-2" onclick="hideUsageModal()">취소</button>
				</div>
			</div>

			<div id="modalOverlay" class="modal-overlay"></div>
		</div>

		<!-- 여긴 높이 보정용 푸터 입니다. -->
		<footer></footer>

		<!-- 데이터 저장 alert메세지 -->
		<c:if test="${not empty msg}">
			<script>
	        	alert('${msg}');
	    	</script>
		</c:if>
</body>
</html>