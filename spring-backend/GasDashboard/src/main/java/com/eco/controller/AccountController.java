package com.eco.controller;

import javax.servlet.http.HttpSession;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.eco.domain.UserVO;

import lombok.extern.log4j.Log4j;

@Controller
@Log4j
@RequestMapping("/account")
public class AccountController {
	
	// 사용자 계정 관리 페이지로 이동
	@GetMapping("")
	public String adminPage(Model model, HttpSession session, RedirectAttributes redirectAttributes) {
		UserVO user = (UserVO) session.getAttribute("currentUserInfo");
		if (user == null) {
			return "redirect:/login";
		}	
		
		String userType = user.getUser_type();
		if ("admin".equals(userType)) {
			model.addAttribute("currentUserInfo", user);
			return "account";
		} else {
			redirectAttributes.addFlashAttribute("msg", "관리자 계정만 접근 가능합니다.");
			return "redirect:/admin";
		}
	}
}
