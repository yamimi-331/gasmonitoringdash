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
	// 가입자 정보
	public String selectUserCdByUserId(@Param("user_id") String user_id);  // 아이디로 사용자 조회
	public int findMaxUserCd(@Param("year") String year);
	//지역코드
	public List<LocalVO> selectLocalList();
}
