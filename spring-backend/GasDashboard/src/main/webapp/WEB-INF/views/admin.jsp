<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Eco</title>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="../resources/js/admin.js"></script>
<link href="../../resources/css/common.css?after" rel="stylesheet"
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
<style>
.modal-container {
	width: 30%;
	display: none; /* Controlled by JS */
	position: fixed;
	top: 50%;
	left: 50%;
	transform: translate(-50%, -50%);
	background: white;
	padding: 30px;
	border: 1px solid #82cd2b;
	border-radius: 8px;
	z-index: 1000;
	box-shadow: 0 8px 16px rgba(0, 0, 0, 0.2);
	font-size: 20px;
}

.result-inner-container {
	display: flex;
	width: 100%;
	overflow-y: auto;
	flex-direction: column;
	align-items: center;
	min-height: 200px;
	max-height: 500px;
	border: none;
	border-radius: 4px;
	padding: 10px;
	box-sizing: border-box;
}

.inner-container {
	display: flex;
	width: 100%;
	justify-content: center;
	flex-direction: column;
	padding: 10px;
}


.search-container {
	width: 100%;
	display: flex;
	flex-direction: column;
	justify-content: center;
	align-items: flex-start;
	gap: 8px;
	padding: 10px;
	box-sizing: border-box;
	border: none;
	box-shadow: 0 8px 16px rgba(0, 0, 0, 0.2);
	border-radius: 4px;
}

.search-area {
	width: 100%;
	display: flex;
	flex-direction: row;
	justify-content: center;
	align-items: center; /* 추가 */
	gap: 10px;
}

.search-area input[type="text"] {
	height: 36px;
	padding: 0 10px;
	font-size: 20px;
	border: 1px solid #ccc;
	border-radius: 4px;
}

.search-area button.green-btn-admin {
	height: 36px;
	font-size: 20px;
	border: none;
	border-radius: 4px;
	background-color: #008000;
	color: white;
	cursor: pointer;
	padding: 0 5px;
}
.search-area button.green-btn{
	height: 36px;
	font-size: 20px;
	border: none;
	border-radius: 4px;
	background-color: #008000;
	color: white;
	cursor: pointer;
	padding: 0;
}
.search-area button.green-btn:hover {
	background-color: #218838;
}

.search-inner-container {
	display: flex;
	width: 100%;
	flex-direction: column;
	align-items: center;
	min-height: 200px;
	padding: 10px;
	box-sizing: border-box;
}

.type-tab {
	display: flex;
	justify-content: space-around;
	width: 80%;
	align-items: center;
	text-align: center;
	box-sizing: border-box;
	padding: 10px;
}

.type-tab-btn {
	display: flex;
	width: 60%;
	line-height: 50px;
	justify-content: center;
	margin: 0;
	background-color: #c5ee8f;
	color: black;
	cursor: pointer;
	font-size: 20px;
	border: none;
}

.type-tab-btn.active {
	background-color: #008000; /* 활성화 색상 */
	font-weight: bold;
	color: white;
}

.result-container {
	width: 100%;
	display: flex;
	flex-direction: column;
	justify-content: center;
	align-items: flex-start;
	gap: 8px;
	padding: 10px;
	margin-top: 10px;
	box-sizing: border-box;
	border: none;
	box-shadow: 0 8px 16px rgba(0, 0, 0, 0.2);
	border-radius: 4px;
}

.result-inner-container {
	display: flex;
	width: 100%;
	overflow-y: auto;
	flex-direction: column;
	align-items: center;
	min-height: 200px;
	max-height: 500px;
	padding: 10px;
	box-sizing: border-box;
}
.no-margin{
margin:0;
}

</style>
</head>
<body>
	<header>
		<h2 class="header-title">관리자 페이지</h2>
	</header>
	<!-- nav와 main을 가로로 나란히 배치하기위한 컨테이너 -->
	<div class="container">
		<!-- 좌측 네비게이션 start ============================= -->
		<nav class="sidebar-nav">
		  <!-- 상단 환영 메시지 영역 -->
		  <div class="nav-header">
		    <div class="nav-user-info">
		      <span class="user-welcome-text">${currentUserInfo.user_nm} 님, 환영합니다.</span>
		    </div>
		    <div class="nav-logout">
		      <button class="btn btn-logout" onclick="logout()">로그아웃</button>
		    </div>
		  </div>
		
		  <!-- 메뉴 영역 -->
		  <div class="nav-menu">
		    <a class="nav-link" href="/">메인페이지</a>
		  </div>
		
		  <!-- 관리자 전용 메뉴 -->
		  <c:set var="userType" value="${ currentUserInfo.user_type }" />
		  <div class="nav-menu">
		    <c:if test="${ userType=='admin' }">
		      <a class="nav-link" href="/account">사용자 계정 관리</a>
		    </c:if>
		  </div>
		</nav>
		<!-- 좌측 네비게이션 end ============================= -->

		<!-- main start ============================= -->
		<main class="board-page">
			<!-- 사용자 검색 영역 start------------------------------ -->
			<div class="inner-container">
				<div class="search-container">
					<h2 class="no-margin">주소 검색</h2>
					<div class="white-line"></div>
					<div class="search-inner-container">
						<div class="search-area">
							<input type="text" id="searchKeyword" placeholder="주소 입력"
								autocomplete="off" />
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
									<td colspan="4">해당하는 주소에 데이터가 없습니다.</td>
								</tr>
							</tbody>
						</table>
					</div>
				</div>
				<!-- 사용자 검색 영역 end------------------------------ -->

				<!-- 사용자별 에너지 사용량 관리 영역 start ------------------------ -->
				<div id="usageSection" class="result-container">
					<h2 class="no-margin">가스 사용내역</h2>
					<div class="white-line"></div>
					<div class="search-area">
						<button class="green-btn-admin" onclick="showUsageModal('add')">등록</button>
						<button class="green-btn-admin" onclick="showUsageModal('edit')">수정</button>
						<button class="green-btn-admin" onclick="deleteUsage()">삭제</button>
					</div>
					<div class="result-inner-container">
						<table id="usageTable">
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
				</div>


				<div class="modal-field" style="margin-bottom: 20px;">
					<label for="modal_usage_input">사용량:</label> <input type="number"
						id="modal_usage_input" step="0.01" min="0" class="modal-input"
						required>
				</div>

				<div class="modal-buttons">
					<button class="green-btn-2" onclick="saveUsageData()">저장</button>
					<button class="green-btn-2" onclick="hideUsageModal()">취소</button>
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