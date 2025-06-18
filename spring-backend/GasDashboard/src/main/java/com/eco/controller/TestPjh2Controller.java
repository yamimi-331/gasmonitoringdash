package com.eco.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import lombok.extern.log4j.Log4j;

@Controller
@RequestMapping("/testPjh2")
@Log4j
public class TestPjh2Controller {

	@GetMapping("")
	public String showDashboard() {
		log.info("테스트 화면으로이동2");
		return "testPjh2";
	}
}