package com.eco.controller;


import javax.servlet.http.HttpSession;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import com.eco.domain.UserVO;

import lombok.extern.log4j.Log4j;

@Controller
@Log4j
@RequestMapping("/")
public class DashboardController {
	
	@GetMapping("")
	public String dashboardPage(Model model, HttpSession session) {
		UserVO user = (UserVO) session.getAttribute("currentUserInfo");
	    model.addAttribute("currentUserInfo", user);
		return "dashboard";
	}
}
