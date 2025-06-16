package com.eco.controller;

import java.net.URI;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Map;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.client.RestTemplate;

@Controller
public class TestPjhController {
	@GetMapping("/testPjh")
	public String showDashboard() {
		return "testPjh";  // JSP 이름 반환만 하면 됨
	}
}
