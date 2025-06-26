/**
 * 
 */

let isIdChecked = false; // 아이디 중복 확인 완료 여부
let isPwdValid = false;  // 비밀번호 확인 완료 여부

function validateForm() {
    const userIdInput = document.querySelector('input[name="user_id"]');
    const userPwInput = document.querySelector('input[name="user_pw"]');
    const userNmInput = document.querySelector('input[name="user_nm"]');
    const userAddrInput = document.querySelector('input[name="user_addr"]');
    const localCdInput = document.querySelector('input[name="local_cd"]');
    
    const userId = userIdInput.value.trim();
    const userPw = userPwInput.value.trim();
    const userNm = userNmInput.value.trim();
    const userAddr = userAddrInput.value.trim();
    const localCd = localCdInput.value.trim();
    
    if (userId === "" || userId === null) {
        alert("아이디를 입력해주세요.");
        userIdInput.focus();
        return false; // Prevent form submission
    }
    if (!isIdChecked) {
        alert("아이디 중복 확인을 해주세요.");
        userIdInput.focus();
        return false;
    }
    if (userPw === "" || userPw === null) {
        alert("비밀번호를 입력해주세요.");
        userPwInput.focus();
        return false;
    }
    if (!isPwdValid) {
        alert("비밀번호 확인을 완료해주세요.");
        document.querySelector("#user_pw_ck").focus();
        return false;
    }
    if (userNm === "" || userNm === null) {
        alert("이름을 입력해주세요.");
        userNmInput.focus();
        return false;
    }
    // 주소 체크
    if (!localCd || !userAddr) {
        alert("주소를 입력해주세요.");
        document.querySelector("#user_addr").focus();
        return false;
    }
    return true;
}

// 아이디 중복 확인
function checkDuplicateId() {
        const userId = document.querySelector('input[name="user_id"]').value;
        if (!userId) {
            alert("아이디를 입력하세요.");
            userIdInput.focus();
            return;
        }

        fetch("/signup/check-id?user_id=" + encodeURIComponent(userId))
            .then(res => res.text())
            .then(result => {
                if (result === "duplicate") {
                    alert("이미 사용 중인 아이디입니다.");
                    isIdChecked = false;
                } else {
                    alert("사용 가능한 아이디입니다!");
                    isIdChecked = true;
                }
            })
            .catch(err => {
                console.error("중복 확인 에러:", err);
                isIdChecked = false;
            });
}

// 비밀번호 확인 검사
function checkPwd() {
    const pw = document.querySelector("#user_pw").value;
    const pw_ck = document.querySelector("#user_pw_ck").value;

    const pw_ckInput = document.querySelector("#user_pw_ck");
    const feedback = document.querySelector(".invalidFeedback");

    pw_ckInput.classList.remove("is-valid", "is-invalid");
    feedback.textContent = "";
    feedback.style.color = "";

    if (pw === "" || pw_ck === "" || pw !== pw_ck) {
        pw_ckInput.classList.add("is-invalid");
        feedback.textContent = "비밀번호가 일치하지 않습니다.";
        feedback.style.color = "red";
        isPwdValid = false;
    } else {
        pw_ckInput.classList.add("is-valid");
        isPwdValid = true;
    }
}
// 주소 API
function searchAddress() {
    new daum.Postcode({
        oncomplete: function(data) {
        console.log(data);
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
// 이벤트 등록 (DOM 로드 이후 실행)
document.addEventListener("DOMContentLoaded", function () {
    const pwCkInput = document.querySelector("#user_pw_ck");
    const form = document.querySelector("#signupForm");
    const userIdInput = document.querySelector('input[name="user_id"]');

    if (pwCkInput) {
        pwCkInput.addEventListener("input", checkPwd);
    }
    if (form) {
        form.addEventListener("submit", function (event) {
            if (!validateForm()) {
                event.preventDefault();
            }
        });
    }
    if (userIdInput) {
        userIdInput.addEventListener("input", function () {
            isIdChecked = false;
        });
    }
    
});
