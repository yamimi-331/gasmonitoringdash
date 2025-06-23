<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="../resources/js/account.js"></script>
<link href="../../resources/css/common.css?after" rel="stylesheet"
	type="text/css">
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
	border: 1px solid #82cd2b;
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
	background-color: #fefefe;
	border: none;
	box-shadow: 0 8px 16px rgba(0, 0, 0, 0.2);
	border-radius: 4px;
}

.result-container {
	width: 100%;
	display: flex;
	flex-direction: column;
	justify-content: center;
	align-items: flex-start;
	gap: 8px;
	padding: 10px;
	margin-top: 20px;
	box-sizing: border-box;
	background-color: #fefefe;
	border: none;
	box-shadow: 0 8px 16px rgba(0, 0, 0, 0.2);
	border-radius: 4px;
}


</style>
</head>
<body>
	<header>
		<h2 class="header-title">사용자 계정 관리 페이지</h2>
	</header>
	<!-- nav와 main을 가로로 나란히 배치하기위한 컨테이너 -->
	<div class="container">
		<!-- 좌측 네비게이션 start ============================= -->
		<nav class="sidebar-nav">
			<!-- 상단 환영 메시지 영역 -->
			<div class="nav-header">
				<div class="nav-user-info">
					<span class="user-welcome-text">${currentUserInfo.user_nm}
						님, 환영합니다.</span>
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
			<div class="nav-menu">
				<a class="nav-link" href="/admin">관리자 페이지</a>
			</div>
		</nav>
		<!-- 좌측 네비게이션 end ============================= -->

		<!-- main start ============================= -->
		<main class="board-page">
			<div class="inner-container">
			<!-- 사용자 검색 영역 start------------------------------ -->
			<div class="search-container">
			<h2 class="no-margin">권한 승인 대기 목록</h2>
			<div class="black-line"></div>
			<table>
				<colgroup>
					<col width="25%">
					<col width="25%">
					<col width="25%">
					<col width="25%">
				</colgroup>
				<tr>
					<th>아이디</th>
					<th>이름</th>
					<th>현재 등급</th>
					<th>승인 버튼</th>
				</tr>
				<c:choose>
					<c:when test="${not empty manageUser}">
						<c:forEach var="item" items="${manageUser}">
							<tr>
								<td>${item.user_id}</td>
								<td>${item.user_nm}</td>
								<c:choose>
									<c:when test="${ item.user_type == 'preManager' }">
										<td>매니저(승인 요청)</td>
									</c:when>
									<c:when test="${ item.user_type == 'preAdmin' }">
										<td>관리자(승인 요청)</td>
									</c:when>
								</c:choose>
								<td>
									<form method="post" action="/account/approve"
										style="display: inline;" onsubmit="return approveConfirm();">
										<input type="hidden" name="user_cd" value="${item.user_cd}">
										<input type="hidden" name="user_id" value="${item.user_id}">
										<input type="hidden" name="user_type"
											value="${item.user_type}">
										<button type="submit">승인</button>
									</form>
									<form method="post" action="/account/reject"
										style="display: inline;" onsubmit="return rejectConfirm();">
										<input type="hidden" name="user_cd" value="${item.user_cd}">
										<input type="hidden" name="user_id" value="${item.user_id}">
										<button type="submit">거절</button>
									</form>
								</td>
							</tr>
						</c:forEach>
					</c:when>
					<c:otherwise>
						<tr>
							<td colspan="4">${ accountManageMsg }</td>
						</tr>
					</c:otherwise>
				</c:choose>
			</table>
			</div>
			<!-- 사용자 검색 영역 start------------------------------ -->
				<div class="result-container">
					<h2 class="no-margin">사용자 검색</h2>
					<div class="black-line"></div>
					<div class="search-inner-container">
						<div class="search-area">
							<select id="div_year" name="div_year">
								<option value="">-- 등급 선택 --</option>
								<option value="common">일반 회원</option>
								<option value="manager">매니저</option>
								<option value="admin">관리자</option>
							</select> <input type="text" id="searchKeyword" placeholder="아이디 입력"
								autocomplete="off" />
							<button class="green-btn" onclick="searchUser()">검색</button>
						</div>
						<button class="green-btn-admin" onclick="showUsageModal('add')">등록</button>
						<button class="green-btn-admin" onclick="showUsageModal('edit')">수정</button>
						<button class="green-btn-admin" onclick="deleteUsage()">삭제</button>
						<table id="userTable">
							<thead>
								<tr>
									<th style="width: 25%;">선택</th>
									<th style="width: 25%;">아이디</th>
									<th style="width: 25%;">이름</th>
									<th style="width: 25%;">현재 등급</th>
								</tr>
							</thead>
							<tbody>
								<tr>
									<td colspan="4">해당 계정 권한의 사용자가 없습니다.</td>
								</tr>
							</tbody>
						</table>
					</div>
				</div>
			</div>
			<!-- 사용자 검색 영역 end------------------------------ -->
			<!-- 등록 수정 모달 폼 전체 영역 -->
			<div id="usageModal" class="modal-container">
				<h3 id="modalTitle">사용자 권한 관리</h3>
				<input type="hidden" id="modal_user_id">
				<div class="modal-field">
					<select id="modal_year" name="modal_year">
						<option value="">-- 연도 선택 --</option>
						<option value="common">일반 회원</option>
						<option value="manager">매니저</option>
						<option value="admin">관리자</option>
					</select>
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