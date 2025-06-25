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

			// 관리자 권한 요청 계정 조회
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

	// 사용자 등급 변경 승인
	@PostMapping("/approve")
	public String approveUser(UserVO user, RedirectAttributes redirectAttributes) {
		String newType = "";
		switch (user.getUser_type()) {
		case "commonM":
			newType = "manager";
			break;
		case "commonA":
			newType = "admin";
			break;
		case "managerA":
			newType = "admin";
			break;
		default:
			redirectAttributes.addFlashAttribute("msg", "승인할 수 없는 사용자입니다.");
			return "redirect:/account";
		}

		user.setUser_type(newType);
		adminService.changeUserType(user);

		String newTypeStr = "";
		if (newType == "mannager") {
			newTypeStr = "매니저";
		} else {
			newTypeStr = "관리자";
		}

		redirectAttributes.addFlashAttribute("msg", newTypeStr + "로 등급이 변경 되었습니다.");
		return "redirect:/account";
	}

	// 사용자 등급 변경 거절
	@PostMapping("/reject")
	public String rejectUser(UserVO user, RedirectAttributes redirectAttributes) {
		String type = user.getUser_type();
		String resultType= "";
		if(type == "commonM" || type =="commonA") {
			resultType = "common";
		} else if(type == "managerA") {
			resultType = "manager";
		} 
		user.setUser_type(resultType);
		
		adminService.changeUserType(user);

		redirectAttributes.addFlashAttribute("msg", resultType + "으로 등급이 변경 되었습니다.");
		return "redirect:/account";
	}

	// 사용자 이름, 권한 레벨로 사용자 조회
	@PostMapping("/search-users")
	@ResponseBody
	public List<UserVO> searchUsers(@RequestParam String userName, @RequestParam(required = false) String userType) {
		List<UserVO> users = adminService.findUsersByNameAndType(userName, userType);
		return users;
	}

	// 사용자 권한 레벨 수정
	@PostMapping("/update-user-level")
	public String updateUserLevel(UserVO user) {
	    // 등급 변경
	    adminService.changeUserType(user);
	    return "redirect:/account";
	}

}
