package com.eco.service;

import java.util.List;

import org.apache.ibatis.annotations.Param;
import org.springframework.stereotype.Service;

import com.eco.domain.LocalComparisonDTO;
import com.eco.domain.UsageVO;
import com.eco.domain.UserVO;
import com.eco.exception.ServiceException;
import com.eco.mapper.UsageMapper;
import com.eco.mapper.UserMapper;

import lombok.AllArgsConstructor;
import lombok.extern.log4j.Log4j;

@Service
@AllArgsConstructor
@Log4j
public class UsageServiceImpl implements UsageService {
	// MySQL 쿼리 매핑
	private final UsageMapper usageMapper;
	private final UserMapper userMapper;

	// 사용자의 최근 (12개월) 월별 사용량 추이
	@Override
	public List<UsageVO> getRecentUsage(String user_id) {
		try {
			UserVO user = userMapper.selectCdDataByUserId(user_id);
			if (user == null) {
				throw new ServiceException("존재하지 않거나 비활성화된 사용자입니다.");
			}

			return usageMapper.selectRecentUsage(user.getUser_cd());
		} catch (Exception e) {
			throw new ServiceException("최근 12개월 사용량 조회 실패", e);
		}
	}

	// 사용자의 전기사용량 비교 데이터
	@Override
	public LocalComparisonDTO getLocalComparison(String user_id) {
		try {
			UserVO user = userMapper.selectCdDataByUserId(user_id);
			if (user == null) {
				throw new ServiceException("존재하지 않거나 비활성화된 사용자입니다.");
			}
			// 사용자의 전기사용량 비교 데이터
			return usageMapper.selectLocalComparison(user.getUser_cd());
		} catch (Exception e) {
			throw new ServiceException("최근 12개월 사용량 조회 실패", e);
		}
	}

}
