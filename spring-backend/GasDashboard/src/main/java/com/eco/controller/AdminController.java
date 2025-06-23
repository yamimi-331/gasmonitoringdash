package com.eco.controller;

import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpSession;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
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
		UserVO currentUserInfo = (UserVO) session.getAttribute("currentUserInfo");
		if (currentUserInfo != null) {
			model.addAttribute("currentUserInfo", currentUserInfo);
		} else {
			return "redirect:/login";
		}
		return "admin";
	}
	
	// 사용자 검색
	@GetMapping("/search-users")
	@ResponseBody
	public List<AdminDTO> searchUser(@RequestParam("keyword") String keyword) {
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
	public Map<String, Object> insertGasUsage(@RequestBody AdminDTO admin) {

		UserVO user = userService.findByUserId(admin.getUser_id());
		if (user == null) {
	        return Map.of("success", false, "message", "사용자를 찾을 수 없습니다.");
	    }
		admin.setUser_cd(user.getUser_cd());
		admin.setLocal_cd(user.getLocal_cd());
		
		// 날짜 문자열 변환
		String date = admin.getModal_year() + "-" + admin.getModal_month();
		admin.setUsage_dt(date);
	    
		boolean result = adminService.registerUsage(admin);
		return Map.of("success", result);
	}
	
	// 가스 사용량 수정
	@PostMapping("/gas/update")
	@ResponseBody
	public Map<String, Object> updateGas(@RequestBody UsageVO usage) {
		boolean result = adminService.modifyUsage(usage);
		// 서비스 결과에 따라 "success" 키와 함께 boolean 값을 JSON 응답으로 반환
		return Map.of("success", result);
	}
	
	// 가스 삭제
	@PostMapping("/gas/delete")
	@ResponseBody
	public Map<String, Object> deleteGas(@RequestBody UsageVO usage) {
		boolean result = adminService.removeUsage(usage.getUsage_cd());
		// 서비스 결과에 따라 "success" 키와 함께 boolean 값을 JSON 응답으로 반환
		return Map.of("success", result);
	}
}
