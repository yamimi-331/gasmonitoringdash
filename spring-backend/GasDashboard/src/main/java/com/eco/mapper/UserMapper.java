package com.eco.mapper;

import com.eco.domain.UserVO;

public interface UserMapper {

	// 로그인을 통한 사용자 조회
	public UserVO getUserSelect(UserVO user);

}
