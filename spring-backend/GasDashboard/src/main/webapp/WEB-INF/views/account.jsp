<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>DashBoard</title>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="../resources/js/account.js?after"></script>
<link href="../../resources/css/common.css?after" rel="stylesheet"
	type="text/css">
<link href="../../resources/css/admin.css?after" rel="stylesheet"
	type="text/css">
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
				<button class="nav-btn" onclick="logout()">로그아웃</button>
			</div>

			<!-- 메뉴 영역 -->
			<div class="nav-menu">
				<a class="nav-link" href="/">대시보드 페이지</a>
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
			<div class="search-inner-container">
			<div class="table-wrapper">
			<table  class="table-style">
				<colgroup>
					<col width="20%">
					<col width="20%">
					<col width="20%">
					<col width="20%">
					<col width="20%">
				</colgroup>
				<thead>
				<tr>
					<th>사용자번호</th>
					<th>아이디</th>
					<th>이름</th>
					<th>현재 등급</th>
					<th>승인 버튼</th>
				</tr>
				</thead>
				<tbody>
				<c:choose>
					<c:when test="${not empty manageUser}">
						<c:forEach var="item" items="${manageUser}">
							<tr>
								<td>${item.user_cd}</td>
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
										<button class="nav-btn" type="submit">승인</button>
									</form>
									<form method="post" action="/account/reject"
										style="display: inline;" onsubmit="return rejectConfirm();">
										<input type="hidden" name="user_cd" value="${item.user_cd}">
										<input type="hidden" name="user_id" value="${item.user_id}">
										<button  class="nav-btn" type="submit">거절</button>
									</form>
								</td>
							</tr>
						</c:forEach>
					</c:when>
					<c:otherwise>
						<tr>
							<td colspan="4" style="text-align:center;">${ accountManageMsg }</td>
						</tr>
					</c:otherwise>
				</c:choose>
				</tbody>
				
			</table>
			</div>
			
			</div>
			</div>
			<!-- 사용자 권한 등급 수정 start------------------------------ -->
				<div class="result-container">
					<h2 class="no-margin">사용자 권한 등급 수정</h2>
					<div class="black-line"></div>
					<div class="result-inner-container">
						<div class="search-area">
							<select id="div_level" name="div_level">
								<option value="">-- 권한 등급 선택 --</option>
								<option value="common">일반 회원</option>
								<option value="manager">매니저</option>
								<option value="admin">관리자</option>
							</select> <input type="search" id="searchKeyword" placeholder="이름 입력"
								autocomplete="off" />
							<button class="nav-btn" onclick="searchUser()">검색</button>
							<button class="nav-btn" onclick="showLevelModal()">권한 수정</button>
						</div>
						<div class="table-wrapper">
						<table id="userTable" class="table-style">
							<colgroup>
								<col width="25%">
								<col width="25%">
								<col width="25%">
								<col width="25%">
							</colgroup>
							<thead>
							<tr>
								<th>일련번호</th>
								<th>아이디</th>
								<th>이름</th>
								<th>현재 등급</th>
							</tr>
							</thead>
							<tbody>
							<tr>
								<td colspan="4" style="text-align:center;">조회된 사용자가 없습니다.</td>
							</tr>
							</tbody>
						</table>
						</div>
					</div>
				</div>
			</div>
			<!-- 사용자 검색 영역 end------------------------------ -->
			<!-- 사용자 권한 수정 모달 -->
			<div id="levelModal" class="modal-container">
				<h3 id="levelModalTitle">사용자 권한 수정</h3>
				<input type="hidden" id="selectedUserCd">
				<input type="hidden" id="selectedUserId">
				<input type="hidden" id="selectedUserCurrentLevel">
				
				<div class="modal-field">
					<label for="newUserLevel">새로운 권한 등급</label>
					<select id="newUserLevel" name="newUserLevel">
						<option value="">-- 권한 등급 선택 --</option>
						<option value="common">일반 회원</option>
						<option value="manager">매니저</option>
						<option value="admin">관리자</option>
					</select>
					<button class="nav-btn" onclick="saveUserLevel()">저장</button>
					<button class="nav-btn" onclick="hideLevelModal()">취소</button>
				</div>
			</div>
			
			<!-- 모달 오버레이 -->
			<div id="levelModalOverlay" class="modal-overlay"></div>

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