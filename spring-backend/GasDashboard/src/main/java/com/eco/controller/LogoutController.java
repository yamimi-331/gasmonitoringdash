package com.eco.controller;

import javax.servlet.http.HttpSession;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import lombok.AllArgsConstructor;
import lombok.extern.log4j.Log4j;

@Controller
@Log4j
@AllArgsConstructor
@RequestMapping("/logout")
public class LogoutController {
	
	// 로그아웃
	@GetMapping("")
	public String logout(HttpSession session, RedirectAttributes redirectAttributes) {
	    //세션 전체 삭제
		session.invalidate();
		// 세션 사용자정보만 삭제
		//session.removeAttribute("currentUserInfo");

		redirectAttributes.addFlashAttribute("msg", "로그아웃 되셨습니다.");
	    return "redirect:/";
	}
}
