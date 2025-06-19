package com.eco.service;


import com.eco.domain.UserVO;


public interface UserService {
	// 로그인 함수
	public UserVO login(UserVO user);
}
