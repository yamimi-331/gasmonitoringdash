package com.eco.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import com.eco.domain.LocalVO;
import com.eco.domain.UserVO;

public interface UserMapper {

	// 로그인을 통한 사용자 조회
	public UserVO getUserSelect(UserVO user);
	public int Select();
	// 회원가입
	public void userInsert(UserVO user);
	
	// 가입자 정보 조회
	public UserVO selectCdDataByUserId(@Param("user_id") String user_id);
	// user_cd의 일련번호 조회
	public int selectMaxUserCd(@Param("year") String year);
	// 지역코드 전체 가져오기
	public List<LocalVO> selectLocalList();
	// 회원정보 수정
	public int updateUserInfo(UserVO sessionUser);
	// 회원 탈퇴
	public int deactivateUser(@Param("user_cd") String user_cd);
}
