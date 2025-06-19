package com.eco.service;


import java.util.List;

import com.eco.domain.LocalVO;
import com.eco.domain.UserVO;


public interface UserService {
	// 로그인 함수
	public UserVO login(UserVO user);
	
	// 회원가입
	public void signup(UserVO user);
	// 사용자 아이디 존재 여부 확인
	public UserVO findByUserId(String user_id);
	// cd값 조회
	public String findMaxUserCd(String year);
	// 지역코드 조회
	public List<LocalVO> getLocalList();
}
