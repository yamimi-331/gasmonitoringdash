package com.eco.mapper;

import org.apache.ibatis.annotations.Param;

import com.eco.domain.UserVO;

public interface UserMapper {

	// 로그인을 통한 사용자 조회
	public UserVO getUserSelect(UserVO user);
	
	// 회원가입
	public void userInsert(UserVO user);
	// 가입자 정보
	public UserVO findByUserId(@Param("user_id") String user_id, @Param("user_type") String user_type);  // 아이디로 사용자 조회
		
}
