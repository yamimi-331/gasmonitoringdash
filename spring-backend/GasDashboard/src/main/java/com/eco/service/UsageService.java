package com.eco.service;

import java.util.List;

import com.eco.domain.UsageVO;

public interface UsageService {
	// 사용자의 최근 (12개월) 월별 사용량 추이 
	public List<UsageVO> getRecentUsage(String user_id);

}
