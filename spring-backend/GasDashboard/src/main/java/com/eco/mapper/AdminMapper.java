package com.eco.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import com.eco.domain.AdminDTO;
import com.eco.domain.UsageVO;

public interface AdminMapper {
	// 사용자 조회
	public List<AdminDTO> selectUsers(@Param("user_nm") String user_nm);
	
	// 사용량 조회
	public List<UsageVO> selectUsage(@Param("user_cd") String user_cd);
	
	// 사용량 등록
	public int insertUsage(UsageVO usage);
}
