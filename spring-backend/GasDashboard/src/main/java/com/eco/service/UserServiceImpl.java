package com.eco.service;

import org.springframework.stereotype.Service;

import com.eco.domain.UserVO;
import com.eco.exception.ServiceException;
import com.eco.mapper.UserMapper;

import lombok.AllArgsConstructor;
import lombok.extern.log4j.Log4j;


@Service
@AllArgsConstructor
@Log4j
public class UserServiceImpl  implements UserService{
	// MySQL 쿼리 매핑 
	private UserMapper mapper;
	
	// 로그인
	@Override
	public UserVO login(UserVO user) {
		try {
			return mapper.getUserSelect(user);
		} catch (Exception e) {
			throw new ServiceException("로그인 실패", e);
		}
	}
	
	// 회원가입 
		@Override
	public void signup(UserVO user) {
		try {
			mapper.userInsert(user);
		} catch (Exception e) {
			throw new ServiceException("회원가입 실패", e);
		}
	}
		
	// 사용자 ID, Type으로 사용자 정보 반환
	@Override
	public UserVO findByUserId(String user_id) {
		try {
			return mapper.findByUserId(user_id);
		} catch (Exception e) {
			throw new ServiceException("사용자 조회 실패", e);
		}
	}

}
