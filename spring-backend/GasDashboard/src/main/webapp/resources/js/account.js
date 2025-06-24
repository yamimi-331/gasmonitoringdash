function approveConfirm(){
    return confirm('정말 승인하시겠습니까?');
}
function rejectConfirm(){
    return confirm('정말 거절하시겠습니까?');
}


let selectedUserId = null;
let selectedUserCd = null;
let selectedUserLevel = null;

// 사용자 검색 함수
function searchUser() {
	selectedUserId = null;
	const keyword = jQuery("#searchKeyword").val();
	if (!keyword) return alert("아이디를 입력하세요.");
    const userType = jQuery("#div_level").val();
    if (!userType) return alert("권한 등급을 선택하세요.");

    jQuery.ajax({
		url: "/account/search-users",
		type: "POST",
		data: {
			keyword: keyword,
			userType: userType
		},
		dataType: "json", // JSON으로 받기
		success: function(users) {
			const tbody = jQuery("#userTable tbody").empty();

			// 배열이 아니거나 비었을 경우
			if (!Array.isArray(users) || users.length === 0) {
				tbody.append('<tr><td colspan="4" style="text-align:center;">조회된 사용자가 없습니다.</td></tr>');
			}
            else{
                // 결과가 있을 경우
                users.forEach(user => {
                    const rowHtml =
					'<tr onclick="selectUser(\'' + user.user_cd + '\', \'' + user.user_id + '\', \'' + user.user_type + '\')">' +
                    '<td>' + user.user_cd + '</td>' +
                    '<td>' + user.user_id + '</td>' +
                    '<td>' + user.user_nm + '</td>' +
                    '<td>' + convertUserType(user.user_type) + '</td>' +
					'</tr>';
                    tbody.append(rowHtml);
                });
            }
		},
	    error: function(xhr, status, error) {
	        alert("서버 오류 발생: " + xhr.status + " " + xhr.statusText);
	        console.error("서버 오류 내용:", xhr.responseText);
	    }
	});
}

function convertUserType(type) {
	switch (type) {
		case "common": return "일반 회원";
		case "manager": return "직원";
		case "admin": return "관리자";
		default: return "알수없음";
	}
}
// 사용자 선택 함수
function selectUser(userCd, userId, userLevel) {
    // 이미 선택된 사용자를 다시 클릭하면 선택 해제
    if (selectedUserCd === userCd) {
        selectedUserId = null;
        selectedUserCd = null; // 선택 해제
		selectedUserLevel = null;        
        // 모든 <tr> 태그에서 'selected' 클래스 제거
        document.querySelectorAll("#userTable tbody tr").forEach(tr => {
            tr.classList.remove("selected");
        });
        return; // 함수 종료
    }

    selectedUserCd = userCd;
    selectedUserId = userId;
	selectedUserLevel = userLevel;
	
    // 모든 <tr> 태그에서 'selected' 클래스 제거
    document.querySelectorAll("#userTable tbody tr").forEach(tr => {
        tr.classList.remove("selected");
    });

    // userCd가 포함된 td를 찾고, 그 td가 포함된 tr에 'selected' 추가
    const trs = document.querySelectorAll("#userTable tbody tr");

    trs.forEach(tr => {
        const tds = tr.querySelectorAll("td");
        // 첫 번째 td의 텍스트가 userCd와 일치하는지 확인 (user_cd는 첫 번째 열에 있으므로)
        if (tds.length > 0 && tds[0].textContent.trim() === String(userCd)) {
            tr.classList.add("selected");
        }
    });
}
// 모달 열기
function showLevelModal() {
	if (!selectedUserCd || !selectedUserId) {
		return alert("사용자를 선택해주세요.");
	}
	document.getElementById("selectedUserCd").value = selectedUserCd;
	document.getElementById("selectedUserId").value = selectedUserId;
	document.getElementById("selectedUserCurrentLevel").value = selectedUserLevel;
	
	document.getElementById("levelModal").style.display = "block";
	document.getElementById("levelModalOverlay").style.display = "block";
}

// 모달 닫기
function hideLevelModal() {
	document.getElementById("levelModal").style.display = "none";
	document.getElementById("levelModalOverlay").style.display = "none";
}

// 저장버튼 
function saveUserLevel() {
	const userCd = document.getElementById("selectedUserCd").value;
	const userId = document.getElementById("selectedUserId").value;
	const newLevel = document.getElementById("newUserLevel").value;

	if (!newLevel) return alert("권한 등급을 선택하세요.");

	const currentLevel = document.getElementById("selectedUserCurrentLevel").value;
	if (newLevel === currentLevel) {
		alert("현재 권한 등급과 동일합니다. 다른 권한을 선택해주세요.");
		return;
	}
	
	jQuery.ajax({
		url: "/account/update-user-level",
		type: "POST",
		data: {
			user_cd: userCd,
			user_id: userId,
			user_type: newLevel // 필드명을 VO와 일치시킴
		},
		success: function(res) {
			alert('권한이 변경되었습니다.');
			hideLevelModal();
			searchUser(); // 권한 변경 후 재조회
		},
		error: function(xhr) {
			alert("변경 실패: " + xhr.responseText);
		}
	});
}
