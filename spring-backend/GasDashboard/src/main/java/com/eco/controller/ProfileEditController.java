package com.eco.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpSession;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.eco.domain.LocalVO;
import com.eco.domain.UserUpdateDTO;
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
	
	private PasswordEncoder passwordEncoder;
	
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
	@PostMapping("")
	public String updateProfile(@ModelAttribute UserUpdateDTO userDto,
	                            HttpSession session,
	                            RedirectAttributes redirectAttributes) {

	    // 세션에서 현재 사용자 정보 가져오기
	    UserVO sessionUser = (UserVO) session.getAttribute("currentUserInfo");
	    
	    if (sessionUser == null) return "redirect:/login"; // 로그인 안된 경우

	    // 2. 새 비밀번호 변경
	    if (userDto.getUser_new_pw() != null && !userDto.getUser_new_pw().isBlank()) {
	        sessionUser.setUser_pw(passwordEncoder.encode(userDto.getUser_new_pw()));
	    }

	    // local_cd가 비어 있으면 세션의 기존 local_cd로 설정
	    if (userDto.getLocal_cd() == null || userDto.getLocal_cd().trim().isEmpty()) {
	        userDto.setLocal_cd(sessionUser.getLocal_cd());
	    }
	    
	    // 3. 나머지 정보 업데이트
	    sessionUser.setUser_nm(userDto.getUser_nm());
	    sessionUser.setUser_addr(userDto.getUser_addr());
	    sessionUser.setLocal_cd(userDto.getLocal_cd());
	    sessionUser.setUser_type(userDto.getUser_type());
	    
	    // DB 업데이트
	    userService.updateUserInfo(sessionUser);

	    // 세션 정보도 업데이트 (선택적)
	    session.setAttribute("currentUserInfo", sessionUser);

	    // 완료 메시지 또는 마이페이지 이동
	    redirectAttributes.addFlashAttribute("msg", "회원정보가 수정되었습니다.");
	    return "redirect:/myUsage";
	}
	
	@PostMapping("/delete")
	public String deleteMember(HttpSession session, RedirectAttributes redirectAttributes) {
	    UserVO currentUser = (UserVO) session.getAttribute("currentUserInfo");
	    if (currentUser == null) {
	        return "redirect:/login";
	    }

	    try {
	    	userService.deactivateUser(currentUser.getUser_cd());
	        session.invalidate(); // 로그아웃 처리
	        redirectAttributes.addFlashAttribute("msg", "회원 탈퇴가 정상 처리되었습니다.");
	    } catch (Exception e) {
	        redirectAttributes.addFlashAttribute("errorMsg", "회원 탈퇴 처리 중 오류가 발생했습니다.");
	        return "redirect:/profileEdit";
	    }

	    return "redirect:/";
	}
	
	@PostMapping(value = "/verifyPw", produces = "application/json; charset=UTF-8")
	@ResponseBody
	public Map<String, Object> verifyPassword(@RequestBody UserVO vo, HttpSession session) {
		UserVO sessionUser = (UserVO) session.getAttribute("currentUserInfo");
		Map<String, Object> result = new HashMap<>();

	    if (sessionUser == null) {
	        result.put("success", false);
	        result.put("msg", "세션이 만료되었습니다.");
	        return result;
	    }

	    boolean matched = passwordEncoder.matches(vo.getUser_pw(), sessionUser.getUser_pw());
	    result.put("success", matched);
	    result.put("msg", matched ? "확인되었습니다." : "비밀번호가 일치하지 않습니다.");
	    return result;
	}
}
