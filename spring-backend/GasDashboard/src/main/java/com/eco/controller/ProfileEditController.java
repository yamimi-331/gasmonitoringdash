package com.eco.controller;

import java.util.List;

import javax.servlet.http.HttpSession;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.eco.domain.LocalVO;
import com.eco.domain.UserVO;
import com.eco.service.UserService;

import lombok.AllArgsConstructor;
import lombok.extern.log4j.Log4j;

@Controller
@Log4j
@AllArgsConstructor
@RequestMapping("/profileEdit")
public class ProfileEditController {

	private final UserService userService;

	// 회원정보 수정 페이지 진입
	@GetMapping("")
	public String profileEditPage(Model model, HttpSession session) {
		log.info("회원정보 수정");
		UserVO user = (UserVO) session.getAttribute("currentUserInfo");

		if (user == null) {
			return "redirect:/login"; // 세션 만료 시 로그인 페이지로
		}
		
		List<LocalVO> localList = userService.getLocalList(); // 지역 코드 전체 조회
		model.addAttribute("localList", localList); // ★ 지역 리스트 추가
		model.addAttribute("userInfo", user);

		return "profileEdit";
	}
	
	// 회원정보 수정 
	@PostMapping("/profileEdit")
	public String updateProfile(@ModelAttribute UserVO userVo,
	                            HttpSession session,
	                            RedirectAttributes redirectAttributes) {

	    // 세션에서 현재 사용자 정보 가져오기
	    UserVO sessionUser = (UserVO) session.getAttribute("currentUserInfo");

	    if (sessionUser == null) {
	        return "redirect:/login"; // 로그인 안된 경우
	    }

	    // 기존 정보에 새로 입력된 값 반영
	    sessionUser.setUser_pw(userVo.getUser_pw());
	    sessionUser.setUser_nm(userVo.getUser_nm());
	    sessionUser.setLocal_cd(userVo.getLocal_cd());
	    sessionUser.setUser_addr(userVo.getUser_addr());
	    sessionUser.setUser_type(userVo.getUser_type());

	    // DB 업데이트
	    userService.updateUserInfo(sessionUser);

	    // 세션 정보도 업데이트 (선택적)
	    session.setAttribute("currentUserInfo", sessionUser);

	    // 완료 메시지 또는 마이페이지 이동
	    redirectAttributes.addFlashAttribute("msg", "회원정보가 수정되었습니다.");
	    return "redirect:/myUsage";
	}

}
