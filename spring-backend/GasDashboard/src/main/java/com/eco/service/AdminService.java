package com.eco.service;

import java.util.List;

import com.eco.domain.AdminDTO;
import com.eco.domain.UsageVO;
import com.eco.domain.UserVO;

public interface AdminService {
	// 사용자 조회
	public List<AdminDTO> searchUsers(String keyword);
	
	// 사용량 조회
	public List<UsageVO> getUsageByUser(String user_cd);
	
	// 사용량 등록
	public boolean registerUsage(AdminDTO admin);
	
	// 사용량 수정
	public boolean modifyUsage(UsageVO usage);
	
	// 사용량 삭제
	public boolean removeUsage(int usage_cd);
	
	// 관리자 권한 요청 계정 조회
	public List<UserVO> searchPreAccount();
	
	// 사용자 권한 변경 위한 계정 조회
	public List<UserVO> searchAccount(String user_nm, String user_type);
	
	// 사용자 등급 변경
	public boolean changeUserType(UserVO user);
}
