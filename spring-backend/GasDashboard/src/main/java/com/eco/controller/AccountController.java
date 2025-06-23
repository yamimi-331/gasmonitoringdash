package com.eco.controller;

import java.util.List; 

import javax.servlet.http.HttpSession;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.eco.domain.AdminDTO;
import com.eco.domain.UserVO;
import com.eco.service.AdminService;

import lombok.AllArgsConstructor;
import lombok.extern.log4j.Log4j;

@Controller
@Log4j
@AllArgsConstructor
@RequestMapping("/account")
public class AccountController {
	private AdminService adminService;
	
	// 사용자 계정 관리 페이지로 이동
	@GetMapping("")
	public String accountManagePage(Model model, HttpSession session, RedirectAttributes redirectAttributes) {
		UserVO user = (UserVO) session.getAttribute("currentUserInfo");
		if (user == null) {
			return "redirect:/login";
		}	
		
		String userType = user.getUser_type();
		if ("admin".equals(userType)) {
			model.addAttribute("currentUserInfo", user);
			
			//관리자 권한 요청 계정 조회
			List<UserVO> manageUser = adminService.searchPreAccount();
			for(UserVO type : manageUser) {
				String typeName = mapUserTypeToName(type.getUser_type());
				type.setUser_type(typeName);
			}
			model.addAttribute("manageUser", manageUser);
			if (manageUser.isEmpty()) {
				model.addAttribute("accountManageMsg", "권한 요청한 사용자가 없습니다.");
			}
			
			return "account";
		} else {
			redirectAttributes.addFlashAttribute("msg", "관리자 계정만 접근 가능합니다.");
			return "redirect:/admin";
		}
	}
	
	// 사용자 권한 요청 상태 한글로
	private String mapUserTypeToName(String code) {
		switch(code) {
			case "admin": return "관리자";
	        case "manager": return "매니저";
	        case "preManager": return "매니저(승인 요청)";
	        case "preAdmin": return "관리자(승인 요청)";
	        case "common": return "일반 사용자";
		} return "알 수 없음";
	}
	
	// 사용자 검색
	@GetMapping("/search-users")
	@ResponseBody
	public List<UserVO> searchUser(@RequestParam("user_nm") String user_nm, @RequestParam("user_type") String user_type) {
		// 사용자 이름, 타입 검색하여 결과를 List로 반환
		List<UserVO> result = adminService.searchAccount(user_nm, user_type);
		return result;
	}
}
