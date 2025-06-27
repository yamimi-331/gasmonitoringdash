<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ page trimDirectiveWhitespaces="true" %>

<style>

/* active 상태일 때 */
.nav-menu.active {
  background-color: #e0e7ff; /* 기존 hover보다 살짝 연한 파란색 느낌 */
  border-left: 3px solid #6080bb; /* 기존 버튼 색상과 맞춰서 강조 */
}

/* 서브메뉴 기본 숨김 + 애니메이션 */
.submenu {
  max-height: 0;
  overflow: hidden;
  padding-left: 20px;
  transition: max-height 0.3s ease;
}

/* active일 때 서브메뉴 펼침 */
.nav-menu.active .submenu {
  max-height: 150px; /* 적당한 높이 */
}

/* 서브메뉴 링크 */
.submenu a {
  display: block;
  padding: 6px 8px; /* 기존 padding 느낌 유지 */
  color: #4a4a4a; /* 기존 .nav-link 색상보다 살짝 어둡게 */
  font-size: 14px;
  text-decoration: none;
  transition: background-color 0.2s ease;
}
.nav-menu.active > span.nav-link:hover,
.submenu a:hover {
  background-color: #b0c4ff; /* 기존 .nav-link:hover와 비슷하게 */
}

</style>
<!-- 아코디언 형식의 네비게이션 서브메뉴 -->
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
		<%-- 마이페이지 --%>
	    <div class="nav-menu" onclick="toggleSubmenu(this)">
	      <span class="nav-link">마이 페이지</span>
	      <div class="submenu">
	        <a class="nav-link" href="/myUsage">나의 사용량 보기</a>
	        <a class="nav-link" href="/profileEdit">회원정보 수정</a>
	      </div>
	    </div>
	    
		<%--  관리자/매니저만 --%>
	    <c:if test="${currentUserInfo.user_type == 'admin' || currentUserInfo.user_type == 'manager' || currentUserInfo.user_type == 'managerA'}">
	      <div class="nav-menu" onclick="toggleSubmenu(this)">
	        <span class="nav-link">운영 페이지</span>
	        <div class="submenu">
	          <a class="nav-link" href="/admin">직원 페이지</a>
	          <c:if test="${currentUserInfo.user_type == 'admin'}">
	            <a class="nav-link" href="/account">관리자 페이지</a>
	          </c:if>
	        </div>
	      </div>
	    </c:if>
	</c:if>
</nav>
<script>
  function toggleSubmenu(element) {
    const allMenus = document.querySelectorAll('.nav-menu');
    allMenus.forEach(menu => {
      if (menu !== element) menu.classList.remove('active');
    });
    element.classList.toggle('active');
  }

  function closeAllSubmenus() {
    document.querySelectorAll('.nav-menu').forEach(menu => {
      menu.classList.remove('active');
    });
  }
  function logout() {
		let isLogout = confirm("정말 로그아웃 하시겠습니까?");
		if (isLogout) {
			// 확인 눌렀을 때 로그아웃 페이지로 이동
			window.location.href = "/logout";
		}
	}
</script>
