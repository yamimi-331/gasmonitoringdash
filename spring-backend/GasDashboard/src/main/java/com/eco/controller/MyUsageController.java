package com.eco.controller;

import java.util.List;

import javax.servlet.http.HttpSession;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import com.eco.domain.LocalComparisonDTO;
import com.eco.domain.UsageVO;
import com.eco.service.UsageService;

import lombok.AllArgsConstructor;
import lombok.extern.log4j.Log4j;

@Controller
@Log4j
@AllArgsConstructor
@RequestMapping("/myUsage")
public class MyUsageController {
	//  서비스
	private final UsageService service;
	
	// 사용자의 개인 사용량 페이지 진입
	@GetMapping("")
	public String myUsagePage(HttpSession session, Model model) {
		// 세션의 사용자 아이디로 정보 조회
		String userId = (String) session.getAttribute("currentUserId");
	    if (userId == null) {
	        throw new IllegalStateException("로그인이 필요합니다.");
	    }
	    
	    // 사용자의 최근 (12개월) 월별 사용량 추이 
		List<UsageVO> recentUsage = service.getRecentUsage(userId);
		model.addAttribute("recentUsage", recentUsage);
		
		// 가스사용량 비교 
		LocalComparisonDTO localUsage = service.getLocalComparison(userId);
		model.addAttribute("localUsage", localUsage);
		
		return "myUsage";
	}
}
