package com.eco.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import lombok.AllArgsConstructor;
import lombok.extern.log4j.Log4j;

@Controller
@Log4j
@AllArgsConstructor
@RequestMapping("/myUsage")
public class MyUsageController {

	// 로그인 페이지 진입
	@GetMapping("")
	public String myUsagePage() {
		return "myUsage";
	}
}
