/**
 * 
 */
document.addEventListener("DOMContentLoaded", function () {
    const pwField = document.getElementById("userPw");
    const pwCheckField = document.getElementById("pwCheck");
    const pwCheckMsg = document.getElementById("pwCheckMsg");
    const form = document.getElementById("profileEditForm");
    
    const userNmInput = document.querySelector('input[name="user_nm"]');
	
    // 비밀번호 입력 감지
    pwField.addEventListener("input", checkPasswordMatch);
    pwCheckField.addEventListener("input", checkPasswordMatch);

    // 비밀번호 일치 확인
    function checkPasswordMatch() {
        const pw = pwField.value;
        const pwCheck = pwCheckField.value;

        if (pw && pwCheck && pw !== pwCheck) {
            pwCheckField.classList.add("is-invalid");
            pwCheckField.classList.remove("is-valid");
            pwCheckMsg.textContent = "비밀번호가 일치하지 않습니다.";
            pwCheckMsg.style.color = "red";
            return false;
        } else if (pw && pwCheck && pw === pwCheck) {
            pwCheckField.classList.remove("is-invalid");
            pwCheckField.classList.add("is-valid");
            pwCheckMsg.textContent = "비밀번호가 일치합니다.";
            pwCheckMsg.style.color = "green";
            return true;
        } else {
            pwCheckField.classList.remove("is-valid", "is-invalid");
            pwCheckMsg.textContent = "";
            return false;
        }
    }

    // 폼 제출 시 비밀번호 확인
    form.addEventListener("submit", function (e) {
        const userNm = userNmInput.value.trim();
        if (userNm == "" || userNm == null) {
	        alert("이름을 입력해주세요.");
	        userNmInput.focus();
	        e.preventDefault();
	        return;
    	}
    	if (!checkPasswordMatch()) {
            alert("비밀번호가 일치하지 않습니다.");
            pwCheckField.focus();
            e.preventDefault();
            return;
        }
    });

    // 탈퇴 최종 확인 함수
    window.confirmDelete = function () {
    	if (!checkPasswordMatch()) {
            alert("비밀번호가 일치하지 않습니다.");
            pwCheckField.focus();
            return false;
        } else {
	        if (confirm("정말로 회원을 탈퇴하시겠습니까?\n계정복구는 당사로 문의해주시기 바랍니다.")) {
	            document.getElementById('profiledeleteForm').submit();
	            return true;
	        } else {
	            return false;
	        }
	    }
    };
});


// 주소 API
function searchAddress() {
    new daum.Postcode({
        oncomplete: function(data) {
            const fullAddress = data.roadAddress || data.jibunAddress;
            const sido = data.sido; // 예: "서울특별시"

			
            const regionMap = {
                "서울": "서울특별시",
                "인천": "인천광역시",
                "경기": "경기도",
                "부산": "부산광역시",
                "대구": "대구광역시",
                "광주": "광주광역시",
                "대전": "대전광역시",
                "울산": "울산광역시",
                "세종": "세종특별자치시",
                "강원": "강원도",
                "충북": "충청북도",
                "충남": "충청남도",
                "전북": "전라북도",
                "전남": "전라남도",
                "경북": "경상북도",
                "경남": "경상남도",
                "제주특별자치도": "제주특별자치도"
            };

            const localCodeMap = {
                "서울특별시": "L01",
                "인천광역시": "L02",
                "경기도": "L03",
                "부산광역시": "L04",
                "대구광역시": "L05",
                "광주광역시": "L06",
                "대전광역시": "L07",
                "울산광역시": "L08",
                "세종특별자치시": "L09",
                "강원도": "L10",
                "충청북도": "L11",
                "충청남도": "L12",
                "전라북도": "L13",
                "전라남도": "L14",
                "경상북도": "L15",
                "경상남도": "L16",
                "제주특별자치도": "L17"
            };
            
            // 지역 코드 매핑
            const fullSido = regionMap[sido]; // "서울" → "서울특별시"
            const localCd = localCodeMap[fullSido]; // "서울특별시" → "L01"
            
            if (localCd) {
                document.getElementById("local_cd").value = localCd;
            } else {
                alert("선택한 주소는 지원되지 않는 지역입니다.");
                return;
            }

            document.getElementById("user_addr").value = fullAddress;
        }
    }).open();
}