package com.eco.service;


import com.eco.domain.UserVO;


public interface UserService {
	// 로그인 함수
	public UserVO login(UserVO user);
	public int usercount();
	
	// 회원가입
	public void signup(UserVO user);
	// 사용자 아이디 존재 여부 확인
	public UserVO findByUserId(String user_id, String user_type);
}
