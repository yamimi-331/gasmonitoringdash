package com.eco.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import lombok.extern.log4j.Log4j;

@Controller
@RequestMapping("/usage")
@Log4j
public class UsageController {

	@GetMapping("")
	public String usage() {
		return "/usageForm";
	}
}
