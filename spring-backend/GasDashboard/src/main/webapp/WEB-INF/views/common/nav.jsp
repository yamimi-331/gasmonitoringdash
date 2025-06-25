<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!-- 좌측 네비게이션 start ============================= -->
<nav class="sidebar-nav">
	<!-- 상단 환영 메시지 영역 -->
	<div class="nav-header">
		<c:choose>
			<c:when test="${not empty currentUserInfo}">
				<div class="nav-user-info">
					<span class="user-welcome-text">${currentUserInfo.user_nm}
						님, 환영합니다.</span>
				</div>
				<button class="nav-btn" onclick="logout()">로그아웃</button>
			</c:when>
			<c:otherwise>
				<button class="nav-btn" onclick="location.href='/login'">로그인</button>
			</c:otherwise>
		</c:choose>
	</div>

	<!-- 기본 메뉴 -->
	<div class="nav-menu">
		<a class="nav-link" href="/">대시보드 페이지</a>
	</div>

	<!-- 로그인 상태일 때 노출 -->
	<c:if test="${not empty currentUserInfo}">
		<div class="nav-menu">
			<a class="nav-link" href="/myUsage">마이페이지</a>
		</div>
		<div class="nav-menu">
			<a class="nav-link" href="/profileEdit">회원정보수정</a>
		</div>

		<!-- 관리자 및 매니저 메뉴 -->
		<c:if
			test="${currentUserInfo.user_type == 'admin' || currentUserInfo.user_type == 'manager'}">
			<div class="nav-menu">
				<a class="nav-link" href="/admin">관리자 페이지</a>
			</div>
		</c:if>

		<!-- 관리자 전용 메뉴 -->
		<c:if test="${currentUserInfo.user_type == 'admin'}">
			<div class="nav-menu">
				<a class="nav-link" href="/account">사용자 계정 관리</a>
			</div>
		</c:if>
	</c:if>
</nav>
<!-- 좌측 네비게이션 end ============================= -->
