package com.eco.controller;

import java.util.List; 

import javax.servlet.http.HttpSession;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

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
	
	@PostMapping("/approve")
	public String approveUser(UserVO user, RedirectAttributes redirectAttributes) {
		String newType="";
		switch (user.getUser_type()) {
        case "preManager": newType = "manager"; break;
        case "preAdmin": newType = "admin"; break;
        default:
            redirectAttributes.addFlashAttribute("msg", "승인할 수 없는 사용자입니다.");
            return "redirect:/account";
	    }
		
		user.setUser_type(newType);
	    adminService.changeUserType(user);
	    
	    redirectAttributes.addFlashAttribute("msg", "승인이 완료되었습니다.");
	    return "redirect:/account";
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
