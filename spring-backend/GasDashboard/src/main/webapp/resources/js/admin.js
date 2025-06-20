
let selectedUserId = null;
let selectedUserCd = null;
let selectedUsageCd = null;

// 사용자 검색 함수
function searchUser() {
	selectedUserId = null;
	const keyword = jQuery("#searchKeyword").val();
	if (!keyword) return alert("사용자 이름을 입력하세요.");

	jQuery.ajax({
		url: "/admin/search-users",
		type: "GET",
		data: { keyword },
		dataType: "json", // JSON으로 받기
		success: function(users) {
			const tbody = jQuery("#userTable tbody").empty();
			// 사용량 테이블 초기화
			const usageTbody = jQuery("#usageTable tbody").empty();
			const noDataRow = '<tr><td colspan="3">조회된 사용량 데이터가 없습니다.</td></tr>';
			usageTbody.append(noDataRow);
				
			if (users.length === 0) {
				// No users found, display a message
				const noUserRow = '<tr><td colspan="4">조회된 사용자가 없습니다.</td></tr>';
				tbody.append(noUserRow);
			} else {
				users.forEach(user => {
					 // 각 항목을 안전하게 문자열로 변환
					  const rowHtml =
						  '<tr onclick="selectUser(\'' + user.user_id + '\', \'' + user.user_cd + '\')">' +
						    '<td>' + user.user_id + '</td>' +
						    '<td>' + user.user_nm + '</td>' +
						    '<td>' + user.local_nm + '</td>' +
						    '<td>' + user.user_addr + '</td>' +
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

// 사용자 선택 함수
function selectUser(userId, userCd) {
    // 이미 선택된 사용자를 다시 클릭하면 선택 해제
    if (selectedUserId === userId) {
        selectedUserId = null;
        selectedUserCd = null; // 선택 해제
        // 모든 <tr> 태그에서 'selected' 클래스 제거
        document.querySelectorAll("#userTable tbody tr").forEach(tr => {
            tr.classList.remove("selected");
        });
        // 사용량 테이블 초기화 (선택 해제 시)
        const usageTbody = jQuery("#usageTable tbody").empty();
        const noDataRow = '<tr><td colspan="3">조회된 사용량 데이터가 없습니다.</td></tr>';
        usageTbody.append(noDataRow);
        return; // 함수 종료
    }

    selectedUserId = userId;
    selectedUserCd = userCd;

    // 모든 <tr> 태그에서 'selected' 클래스 제거
    document.querySelectorAll("#userTable tbody tr").forEach(tr => {
        tr.classList.remove("selected");
    });

    // userCd가 포함된 td를 찾고, 그 td가 포함된 tr에 'selected' 추가
    const trs = document.querySelectorAll("#userTable tbody tr");

    trs.forEach(tr => {
        const tds = tr.querySelectorAll("td");
        // 첫 번째 td의 텍스트가 userCd와 일치하는지 확인 (user_cd는 첫 번째 열에 있으므로)
        if (tds.length > 0 && tds[0].textContent.trim() === String(userId)) {
            tr.classList.add("selected");
        }
    });

    //공통 호출
    loadUsageData();
}

// 가스사용량 조회
function loadUsageData() {
	jQuery.ajax({
		url: '/admin/user/'+selectedUserCd+'/usage',
		type: "GET",
		dataType: "json",
		success: function(data) {
			renderUsageTable(data, 'GAS');
		}
	});
}

// 테이블 렌더 함수
function renderUsageTable(data) {
	if (!Array.isArray(data)) {
		alert("데이터 형식이 잘못되었습니다.");
		return;
	}

	const tbody = jQuery("#usageTable tbody").empty();
	selectedUsageCd = null;
	
	if (data.length === 0) {
		const noDataRow = '<tr><td colspan="3">조회된 사용량 데이터가 없습니다.</td></tr>';
		tbody.append(noDataRow);
	} else {
		data.forEach(row => {
			const usage = row.usage_amount;
            const timeStr = row.usage_dt;

            const trHtml =
                '<tr data-id="' + row.usage_cd + '" onclick="selectRow(this, ' + row.usage_cd + ')">' +
                    '<td><input type="radio" name="selectUsage" value="' + row.usage_cd + '" onclick="event.stopPropagation(); selectRow(this.closest(\'tr\'), ' + row.usage_cd + ')"></td>' + 
                    '<td class="date">' + timeStr + '</td>' +
                    '<td class="usage">' + usage + '</td>' +
                '</tr>';

            tbody.append(trHtml);
		});
	}
}


// 사용량 행 선택 함수
function selectRow(clickedTr, usageCd) {
    // 이미 선택된 사용량을 다시 클릭하면 선택 해제
    if (selectedUsageCd === usageCd) {
        selectedUsageCd = null; // 선택 해제
        jQuery(clickedTr).removeClass("selected"); // 해당 행의 배경색 제거
        jQuery(clickedTr).find('input[name="selectUsage"]').prop('checked', false); // 라디오 버튼 체크 해제
        return; // 함수 종료
    }

    selectedUsageCd = usageCd;

    // 모든 <tr> 태그에서 'selected' 클래스 제거
    jQuery("#usageTable tbody tr").removeClass("selected");

    // 클릭된 행에 'selected' 클래스 추가
    jQuery(clickedTr).addClass("selected");

    // 해당 행의 라디오 버튼을 체크합니다.
    jQuery("#usageTable tbody tr").find('input[name="selectUsage"]').prop('checked', false); // 모든 라디오 버튼 먼저 해제
    jQuery(clickedTr).find('input[name="selectUsage"]').prop('checked', true); // 클릭된 라디오 버튼만 체크
}


// 사용량 제거 함수
function deleteUsage() {
	if (!selectedUsageCd) return alert("삭제할 행을 선택하세요.");
	if (!confirm("정말 삭제하시겠습니까?")) return;

	jQuery.ajax({
		url: "/admin/gas/delete",
		type: "POST",
		contentType: "application/json",
		data: JSON.stringify({ usage_cd: selectedUsageCd }),
		success: function() {
			alert("가스 사용내역이 삭제되었습니다.");
			loadUsageData();
		},
        error: function(xhr) {
			alert("삭제 중 오류가 발생했습니다: " + xhr.statusText);
		}
	});
}


//새로운 모달 관련 함수
function showUsageModal(mode) {
    // 공통 필드 초기화 (취소 후 다시 열었을 때 데이터 남아있는 것 방지)
    jQuery("#modal_year").val('');
    jQuery("#modal_month").val('');
    jQuery("#modal_usage_input").val('');
    jQuery("#modal_usage_cd").val(''); // usageCd 초기화 (수정 아닐 시 비워둠)

    jQuery("#modal_mode").val(mode); // 모드 설정 ('add' 또는 'edit')
    jQuery("#modal_user_id").val(selectedUserId); // 현재 선택된 사용자 코드 설정

    if (mode === 'add') {
        if (!selectedUserId) {
            alert('사용자를 선택해주세요.');
            hideUsageModal(); // 모달 띄우지 않고 바로 닫기
            return;
        }
    } else if (mode === 'edit') {
        if (!selectedUsageCd) {
            alert("수정할 행을 선택하세요.");
            hideUsageModal(); // 모달 띄우지 않고 바로 닫기
            return;
        }
        jQuery("#modalTitle").text("사용량 수정");

        const row = jQuery("tr[data-id='" + selectedUsageCd + "']");
        const dateStr = row.find(".date").text();
        const usageVal = row.find(".usage").text();

        const [year, month] = dateStr.split('-');
        jQuery("#modal_year").val(year);
        jQuery("#modal_month").val(month);
        // 날짜는 수정 불가하게 비활성화
        jQuery("#modal_year").prop('disabled', true);
        jQuery("#modal_month").prop('disabled', true);

        jQuery("#modal_usage_cd").val(selectedUsageCd);
        jQuery("#modal_usage_input").val(usageVal);
    } else {
        alert("알 수 없는 모드입니다.");
        return;
    }
    jQuery("#usageModal").show();
    jQuery("#modalOverlay").show();
}

function hideUsageModal() {
    jQuery("#usageModal").hide();
    jQuery("#modalOverlay").hide();
    // 폼 내용 초기화
    jQuery("#modal_usage_cd").val('');
    jQuery("#modal_date").val('');
    jQuery("#modal_usage_input").val('');
    jQuery("#modal_year").prop('disabled', false);
    jQuery("#modal_month").prop('disabled', false);// 다시 활성화
}

// 모달 내 '저장' 버튼 클릭 시 호출될 함수
function saveUsageData() {
    const mode = jQuery("#modal_mode").val();
    const userId = jQuery("#modal_user_id").val();
    const usageCd = jQuery("#modal_usage_cd").val(); // 수정 시에만 사용
    const year = $("#modal_year").val();
    const month = $("#modal_month").val();
    const usage = parseFloat($("#modal_usage_input").val());
    
    if (!userId) {
        alert("사용자가 선택되지 않았습니다.");
        return;
    }
    if (!year || !month || isNaN(usage) || usage < 0) { 
        alert("모든 필드를 올바르게 입력해주세요.");
        return;
    }

    let url;
    let data;

    if (mode === 'add') {
        url = '/admin/gas/insert';
        data = {
            user_id: userId,
            modal_year: year,
            modal_month: month,
            usage_amount: usage
        }
    } else if (mode === 'edit') {
        // 수정 시에는 usageCd가 필수
        if (!usageCd) {
            alert("수정할 사용량 데이터가 선택되지 않았습니다. 다시 선택해주세요.");
            return;
        }
        url = '/admin/gas/update';
        data = {
            usage_cd: usageCd,
            user_id: userId,
            usage_amount: usage
        }
    } else {
        alert("알 수 없는 모드입니다.");
        return;
    }
    
    jQuery.ajax({
        url: url,
        method: 'POST',
        data: JSON.stringify(data),
        contentType: 'application/json',
        dataType: 'json',
        success: function (response) {
            if (response.success  === true || response === 'true') {
                alert(mode === 'add' ? '사용량 등록 성공' : '사용량 수정 성공');
                loadUsageData(); // 데이터 새로고침
                hideUsageModal(); // 모달 닫기
            } else {
                alert(mode === 'add' ? '사용량 등록 실패' : '사용량 수정 실패 (서버 응답 오류)');
            }
        },
        error: function (xhr, status, error) {
            alert('서버 통신 오류가 발생했습니다. 개발자 도구 콘솔을 확인해주세요.');
            console.error('AJAX Error Status:', status);
            console.error('AJAX Error:', error);
            console.error('AJAX Response Text:', xhr.responseText);
            console.error('AJAX XHR Object:', xhr);
        }
    });
}