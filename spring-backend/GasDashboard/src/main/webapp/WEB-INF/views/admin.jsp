<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>DashBoard</title>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="../resources/js/admin.js"></script>
<link href="../../resources/css/common.css?after" rel="stylesheet"
	type="text/css">
<link href="../../resources/css/admin.css?after" rel="stylesheet"
	type="text/css">
<script>
	function logout() {
		let isLogout = confirm("정말 로그아웃 하시겠습니까?");
		if (isLogout) {
			// 확인 눌렀을 때 로그아웃 페이지로 이동
			window.location.href = "/logout";
		}
	}
</script>
</head>
<body>
	<header>
		<h2 class="header-title">관리자 페이지</h2>
	</header>
	<!-- nav와 main을 가로로 나란히 배치하기위한 컨테이너 -->
	<div class="container">
		<jsp:include page="/WEB-INF/views/common/nav.jsp" />

		<!-- main start ============================= -->
		<main class="board-page">
			<!-- 사용자 검색 영역 start------------------------------ -->
			<div class="inner-container">
				<div class="search-container">
					<h2 class="no-margin">주소 검색</h2>
					<div class="black-line"></div>
					<div class="search-inner-container">
						<div class="search-area">
							<input type="search" id="searchKeyword" placeholder="주소 입력"
								autocomplete="off" />
							<button class="nav-btn" onclick="searchUser()">검색</button>
						</div>
						<div class="table-wrapper">
							<table id="userTable" class="table-style">
								<thead>
									<tr>
										<th style="width: 20%">사용자번호</th>
										<th style="width: 20%">아이디</th>
										<th style="width: 20%">이름</th>
										<th style="width: 20%">지역</th>
										<th style="width: 20%">상세주소</th>
									</tr>
								</thead>
								<tbody>
									<tr>
										<td colspan="5">해당하는 주소에 데이터가 없습니다.</td>
									</tr>
								</tbody>
							</table>
						</div>
					</div>
				</div>
				<!-- 사용자 검색 영역 end------------------------------ -->

				<!-- 사용자별 에너지 사용량 관리 영역 start ------------------------ -->
				<div id="usageSection" class="result-container">
					<h2 class="no-margin">가스 사용내역</h2>
					<div class="black-line"></div>
					<div class="result-inner-container">
						<div class="search-area">
							<h3 class="no-margin">날짜 선택</h3>
							<button class="nav-btn" onclick="showUsageModal('add')">등록</button>
							<button class="nav-btn" onclick="showUsageModal('edit')">수정</button>
							<button class="nav-btn" onclick="deleteUsage()">삭제</button>
						</div>
						<div class="table-wrapper">
						<table id="usageTable" class="table-style">
							<thead>
								<tr>
									<th style="width: 20%;">선택</th>
									<th style="width: 40%;">날짜</th>
									<th style="width: 40%;">사용량</th>
								</tr>
							</thead>
							<tbody>
								<tr>
									<td colspan="3">조회된 사용량 데이터가 없습니다.</td>
								</tr>
							</tbody>
						</table>
						</div>
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
				<fieldset  class="modal-field">
					<legend>사용 일자:</legend>
					<select id="modal_year" name="modal_year">
						<option value="">-- 연도 선택 --</option>
						<option value="2020">2020년</option>
						<option value="2021">2021년</option>
						<option value="2022">2022년</option>
						<option value="2023">2023년</option>
						<option value="2024">2024년</option>
						<option value="2025">2025년</option>
					</select> <select id="modal_month" name="modal_month">
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

				<div class="modal-field">
					<label for="modal_usage_input">사용량:</label> <input type="number"
						id="modal_usage_input" step="0.01" min="0" class="modal-input"
						required>
					<button class="nav-btn" onclick="saveUsageData()">저장</button>
					<button class="nav-btn" onclick="hideUsageModal()">취소</button>
				</div>
			</div>

			<div id="modalOverlay" class="modal-overlay"></div>
		</main>
		<!-- main end ============================= -->
	</div>
	<!-- nav와 main을 가로로 나란히 배치하기위한 컨테이너 End ---------- -->

	<footer></footer>

	<!-- 데이터 저장 alert메세지 -->
	<c:if test="${not empty msg}">
		<script>
			alert('${msg}');
		</script>
	</c:if>
</body>
</html>