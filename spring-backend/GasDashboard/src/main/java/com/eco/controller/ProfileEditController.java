package com.eco.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import lombok.AllArgsConstructor;
import lombok.extern.log4j.Log4j;

@Controller
@Log4j
@AllArgsConstructor
@RequestMapping("/profileEdit")
public class ProfileEditController {

	// 회원정보 수정 페이지 진입
	@GetMapping("")
	public String loginPage(Model model) {
		log.info("회원정보 수정");
		return "profileEdit";
	}
}
