package com.eco.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.eco.domain.UserVO;
import com.eco.service.UserService;

import lombok.AllArgsConstructor;
import lombok.extern.log4j.Log4j;

@Controller
@Log4j
@AllArgsConstructor
@RequestMapping("/signup")
public class SignupController {
	
	private UserService service;
	
	// 회원가입 페이지로 이동
	@GetMapping("")
	public String signupPage(Model model) {
		// 지역코드 조회 후 sign up 페이지로 전달
		model.addAttribute("localList", service.getLocalList());
		return "signup";
	}
	
	// 회원가입 DB INSERT
	@PostMapping("")
	public String signupPost(UserVO user) {
		service.signup(user);
		return "login";
	}
	
	// 아이디 중복 확인
	@GetMapping("/check-id")
	@ResponseBody
	public String checkUserId(@RequestParam("user_id") String userId) {
	    UserVO user = service.findByUserId(userId);
	    return (user != null) ? "duplicate" : "available";
	}

}