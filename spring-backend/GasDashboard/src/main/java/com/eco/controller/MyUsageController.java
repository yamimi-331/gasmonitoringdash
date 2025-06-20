package com.eco.controller;

import java.util.List;

import javax.servlet.http.HttpSession;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.eco.domain.UsageVO;
import com.eco.domain.UserVO;
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
		
		String userId = (String) session.getAttribute("currentUserId");
		
	    if (userId == null) {
	        throw new IllegalStateException("로그인이 필요합니다.");
	    }
	    
	    // 사용자의 최근 (12개월) 월별 사용량 추이 
		List<UsageVO> recentUsage = service.getRecentUsage(userId);
		model.addAttribute("recentUsage", recentUsage);
		
		// 가스사용량 비교 
		// 필요 데이터: 지역명(LocalVO) + 지역 당월 사용량 평균(PublicVO) + 당월사용(UsageVO) + 전년동월(UsageVO) + 연간평균(UsageVO)
		// 리턴타입 LocalComparisonDTO
		
		return "myUsage";
	}
}
