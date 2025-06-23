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
	// 회원정보 수정함수
	public void updateUserInfo(UserVO sessionUser);
	// 회원 탈퇴
	public void deactivateUser(String user_cd);
}
