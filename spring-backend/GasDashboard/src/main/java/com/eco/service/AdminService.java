package com.eco.service;

import java.util.List;

import com.eco.domain.AdminDTO;
import com.eco.domain.UsageVO;

public interface AdminService {
	// 사용자 조회
	public List<AdminDTO> searchUsers(String user_nm);
	
	// 사용량 조회
	public List<UsageVO> getUsageByUser(String user_cd);
	
	// 사용량 등록
	public boolean insertUsage(UsageVO usage);
}
