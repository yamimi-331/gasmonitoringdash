package com.eco.controller;

import javax.servlet.http.HttpSession;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import lombok.extern.log4j.Log4j;

@Controller
@Log4j
@RequestMapping("/")
public class IndexController {
	@GetMapping("")
	public String indexPage(Model model, HttpSession session) {
	    String userNm = (String) session.getAttribute("currentUserNm");
	    model.addAttribute("userNm", userNm);
		return "index";
	}
}
