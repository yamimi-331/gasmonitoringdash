package com.eco.controller;

import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpSession;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.eco.domain.AdminDTO;
import com.eco.domain.UsageVO;
import com.eco.domain.UserVO;
import com.eco.service.AdminService;
import com.eco.service.UserService;

import lombok.AllArgsConstructor;
import lombok.extern.log4j.Log4j;

@Controller
@Log4j
@AllArgsConstructor
@RequestMapping("/admin")
public class AdminController {
	private AdminService adminService;
	private UserService userService;
	
	// 관리자 페이지 이동
	@GetMapping("")
	public String adminPage(Model model, HttpSession session) {
		UserVO user = (UserVO) session.getAttribute("currentUserInfo");
		model.addAttribute("currentUserInfo", user);
		return "admin";
	}
	
	// 사용자 검색
	@GetMapping("/search-users")
	@ResponseBody
	public List<AdminDTO> searchUser(@RequestParam String keyword) {
		// 사용자 이름 기반으로 검색하여 결과를 List로 반환
		List<AdminDTO> result = adminService.searchUsers(keyword);
		return result;
	}
	
	// 가스 사용내역 조회
	@GetMapping("/user/{userCd}/usage")
	@ResponseBody
	public List<UsageVO> getGasUsage(@PathVariable String userCd) {
		// 사용자 cd값 기준 가스 사용량 전체 조회
		return adminService.getUsageByUser(userCd);
	}
	
	// 가스 사용량 등록
	@PostMapping("/gas/insert")
	@ResponseBody
	public Map<String, Object> insertGasUsage(@RequestParam("modal_year") String year,
			@RequestParam("modal_month") String month, @ModelAttribute UsageVO usage) {
		if (year == null || month == null || year.isEmpty() || month.isEmpty()) {
		    return Map.of("success", false, "message", "사용 일자를 선택해주세요.");
		}
		if (usage.getUser_cd() == null || usage.getUser_cd().isEmpty()) {
	        return Map.of("success", false, "message", "사용자를 선택해주세요.");
	    }
		String date = year + "-" + month;
	    usage.setUsage_dt(date);
	    
	    UserVO user = userService.getUserByCd(usage.getUser_cd());
	    if (user == null || user.getLocal_cd() == null) {
	        return Map.of("success", false, "message", "사용자의 지역코드를 찾을 수 없습니다.");
	    }
	    usage.setLocal_cd(user.getLocal_cd());
		
		boolean result = adminService.insertUsage(usage);
		return Map.of("success", result);
	}
}
