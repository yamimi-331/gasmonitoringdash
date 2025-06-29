package com.eco.controller;

import javax.servlet.http.HttpSession;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import com.eco.domain.UserVO;
import com.eco.service.UserService;

import lombok.AllArgsConstructor;
import lombok.extern.log4j.Log4j;

@Controller
@Log4j
@AllArgsConstructor
@RequestMapping("/login")
public class LoginController {
	// 사용자 서비스
	private final UserService service;
	
	// 로그인 페이지 진입
	@GetMapping("")
	public String loginPage() {
		return "login";
	}

	// 로그인 버튼 클릭시 실행
	@PostMapping("")
	public String loginPost(UserVO user, HttpSession session, Model model) {
		UserVO rtnUser = service.login(user);
		if (rtnUser != null) {
			// 로그인 성공 처리
			session.setAttribute("currentUserInfo", rtnUser);
			return "redirect: /";
		} else {
			// 로그인 실패 처리
			model.addAttribute("message", "아이디 및 비밀번호가 틀립니다.");
			return "login";
		}
	}
}
