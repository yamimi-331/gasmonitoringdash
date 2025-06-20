package com.eco.service;

import java.util.List;

import com.eco.domain.LocalComparisonDTO;
import com.eco.domain.UsageVO;

public interface UsageService {
	// 사용자의 최근 (12개월) 월별 사용량 추이 
	public List<UsageVO> getRecentUsage(String user_id);
	// 사용자의 전기사용량 비교 데이터
	public LocalComparisonDTO getLocalComparison(String user_id);

}
