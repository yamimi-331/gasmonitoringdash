package com.eco.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import com.eco.domain.LocalComparisonDTO;
import com.eco.domain.UsageVO;

public interface UsageMapper {
	// 최근(12개월) 사용자의 사용량 조회
	public List<UsageVO> selectRecentUsage(@Param("user_cd") String userCd);
	// 사용자의 전기사용량 비교 데이터
	public LocalComparisonDTO selectLocalComparison(@Param("user_cd") String userCd);
}
