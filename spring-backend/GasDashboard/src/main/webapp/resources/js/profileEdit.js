/**
 * 
 */
    // 비밀번호 인증 여부 전역 변수 (컨트롤러에서 인증 후 true로 변경한다고 가정)
let isPasswordVerified = false; // 인증 여부 전역 관리

document.addEventListener("DOMContentLoaded", function () {
    const pwField = document.getElementById("userPw");
    const pwNewField = document.getElementById("pwNew");
    const pwCheckField = document.getElementById("pwCheck");
    const pwCheckMsg = document.getElementById("pwCheckMsg");
    const newPwMsg = document.getElementById("newPwMsg");
    const form = document.getElementById("profileEditForm");
    const userNmInput = document.querySelector('input[name="user_nm"]');
    const userAddrInput = document.getElementById("user_addr");
    const localCdInput = document.getElementById("local_cd");
    const userTypeInputs = document.querySelectorAll('input[name="user_type"]');

    // 새 비밀번호가 현재 비밀번호와 같은지 확인하는 함수
    function checkOldPwNewPwMatch() {
        const currentPw = pwField.value.trim();
        const newpw = pwNewField.value.trim();

        if (newPwMsg) {
            newPwMsg.textContent = "";
            newPwMsg.style.color = "";
        }

        if (newpw !== "" && currentPw !== "" && newpw === currentPw) {
            if (newPwMsg) {
                newPwMsg.textContent = "현재 비밀번호와 동일합니다.";
                newPwMsg.style.color = "red";
            }
            return false;
        }
        return true;
    }

    // 비밀번호 일치 확인 함수 (새 비밀번호와 확인 비밀번호)
    function checkPasswordMatch() {
        const newpw = pwNewField.value.trim();
        const pwCheck = pwCheckField.value.trim();

        pwCheckMsg.textContent = "";
        pwCheckMsg.style.color = "";

        if (newpw === "" && pwCheck === "") {
            pwCheckField.classList.remove("is-invalid", "is-valid");
            return true;
        }

        if (!checkOldPwNewPwMatch()) {
            pwCheckField.classList.add("is-invalid");
            pwCheckField.classList.remove("is-valid");
            pwCheckMsg.textContent = "";
            return false;
        }

        if (newpw !== pwCheck) {
            pwCheckField.classList.add("is-invalid");
            pwCheckField.classList.remove("is-valid");
            pwCheckMsg.textContent = "비밀번호가 일치하지 않습니다.";
            pwCheckMsg.style.color = "red";
            return false;
        } else {
            pwCheckField.classList.remove("is-invalid");
            pwCheckField.classList.add("is-valid");
            pwCheckMsg.textContent = "비밀번호가 일치합니다.";
            pwCheckMsg.style.color = "green";
            return true;
        }
    }

    pwNewField.addEventListener("input", checkPasswordMatch);
    pwCheckField.addEventListener("input", checkPasswordMatch);

    // 변경사항 체크 함수
    function isFormChanged() {
        const originalUserNm = userNmInput.getAttribute("data-original") || "";
        const originalUserAddr = userAddrInput.getAttribute("data-original") || "";
        const originalLocalCd = localCdInput.getAttribute("data-original") || "";
        let originalUserType = "";
        userTypeInputs.forEach(radio => {
            if (radio.hasAttribute("data-original-checked")) originalUserType = radio.value;
        });

        const currentUserNm = userNmInput.value.trim();
        const currentUserAddr = userAddrInput.value.trim();
        const currentLocalCd = localCdInput.value.trim();
        let currentUserType = "";
        userTypeInputs.forEach(radio => {
            if (radio.checked) currentUserType = radio.value;
        });

        const newPwVal = pwNewField.value.trim();

        return (
            currentUserNm !== originalUserNm ||
            currentUserAddr !== originalUserAddr ||
            currentLocalCd !== originalLocalCd ||
            currentUserType !== originalUserType ||
            newPwVal !== ""
        );
    }

    // 처음 로드 시점에 데이터-original 속성으로 원본 저장 (없으면 이 코드 생략 가능)
    userNmInput.setAttribute("data-original", userNmInput.value.trim());
    userAddrInput.setAttribute("data-original", userAddrInput.value.trim());
    localCdInput.setAttribute("data-original", localCdInput.value.trim());
    userTypeInputs.forEach(radio => {
        if (radio.checked) {
            radio.setAttribute("data-original-checked", "true");
        } else {
            radio.removeAttribute("data-original-checked");
        }
    });

    form.addEventListener("submit", function (e) {
        if (userNmInput.value.trim() === "") {
            alert("이름을 입력해주세요.");
            userNmInput.focus();
            e.preventDefault();
            return;
        }

        if (!isPasswordVerified) {
            alert("현재 비밀번호 확인을 먼저 해주세요.");
            pwField.focus();
            e.preventDefault();
            return;
        }

        if (!checkPasswordMatch()) {
            e.preventDefault();
            return;
        }

        if (!isFormChanged()) {
            alert("수정된 정보가 없습니다.");
            e.preventDefault();
            return;
        }
    });

    window.confirmDelete = function () {
        if (!checkPasswordMatch()) {
            alert("비밀번호가 일치하지 않습니다.");
            pwCheckField.focus();
            return false;
        }
        return confirm("정말로 회원을 탈퇴하시겠습니까?\n계정복구는 당사로 문의해주시기 바랍니다.");
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

//비밀번호 검증
function verifyPassword() {
  const currentPw = document.getElementById("userPw").value;
  if (!currentPw) {
    alert("비밀번호를 입력해주세요.");
    return;
  }

  fetch("/profileEdit/verifyPw", {
    method: "POST",
    headers: {
      "Content-Type": "application/json"
    },
    body: JSON.stringify({ user_pw: currentPw })
  })
  .then(res => res.json())
  .then(data => {
    if (data.success) {
      isPasswordVerified = true;  // 인증 완료
      document.getElementById("userPw").readOnly = true;
      document.getElementById("userPw").style.backgroundColor = "#eee";

      document.getElementById("pwNew").readOnly = false;
      document.getElementById("pwCheck").readOnly = false;

      document.getElementById("pwVerifyMsg").textContent = "비밀번호 확인 완료";
      document.getElementById("pwVerifyMsg").style.color = "green";
    } else {
	  isPasswordVerified = false;
      document.getElementById("pwVerifyMsg").textContent = "비밀번호가 일치하지 않습니다.";
      document.getElementById("pwVerifyMsg").style.color = "red";
    }
  });
}


