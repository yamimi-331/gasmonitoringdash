package com.eco.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import com.eco.domain.AdminDTO;
import com.eco.domain.UsageVO;
import com.eco.domain.UserVO;

public interface AdminMapper {
	// 사용자 조회
	public List<AdminDTO> selectUsers(@Param("keyword") String user_nm);
	
	// 사용량 조회
	public List<UsageVO> selectUsageByUser(@Param("user_cd") String user_cd);
	
	// 사용량 등록
	public int insertUsage(AdminDTO admin);
	
	// 사용량 수정
	public int updateUsage(UsageVO usage);
	
	// 사용량 삭제
	public int deleteUsage(int usage_cd);
	
	// 관리자 권한 요청 계정 조회
	public List<UserVO> selectPreAccount();

	// 사용자 권한 변경 위한 계정 조회
	public List<UserVO> selectAccount(@Param("user_nm") String user_nm, @Param("user_type") String user_type);
	
	// 사용자 권한 변경
	public int updateUserType(UserVO user);
	
	// 사용자 정보조회
	public List<UserVO> selectUserByNameAndType(@Param("user_nm") String user_nm, @Param("user_type")  String user_type);
}
