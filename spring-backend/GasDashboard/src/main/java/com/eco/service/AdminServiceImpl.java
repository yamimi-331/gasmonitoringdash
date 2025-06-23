package com.eco.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.eco.domain.AdminDTO;
import com.eco.domain.UsageVO;
import com.eco.domain.UserVO;
import com.eco.exception.ServiceException;
import com.eco.mapper.AdminMapper;

import lombok.AllArgsConstructor;
import lombok.extern.log4j.Log4j;

@Service
@AllArgsConstructor
@Log4j
public class AdminServiceImpl implements AdminService{
	
	private AdminMapper mapper;
	
	// 사용자 조회
	@Override
	public List<AdminDTO> searchUsers(String keyword) {
		return mapper.selectUsers(keyword);
	}

	// 사용량 조회
	@Override
	public List<UsageVO> getUsageByUser(String user_cd) {
		return mapper.selectUsageByUser(user_cd);
	}

	// 사용량 등록
	@Override
	public boolean registerUsage(AdminDTO admin) {
		try {
			int rows = mapper.insertUsage(admin);
			return rows > 0;
		} catch (Exception e) {
			throw new ServiceException("가스 사용량 등록 실패", e);
		}
	}
	
	// 사용량 수정
	@Override
	public boolean modifyUsage(UsageVO usage) {
		try {
			int rows = mapper.updateUsage(usage);
			return rows > 0;
		} catch (Exception e) {
			throw new ServiceException("가스 사용량 수정 실패", e);
		}
	}
	
	// 사용량 삭제
	@Override
	public boolean removeUsage(int usage_cd) {
		try {
			int rows = mapper.deleteUsage(usage_cd);
			return rows > 0;
		} catch (Exception e) {
			throw new ServiceException("가스 사용량 삭제 실패", e);
		}
	}

	// 관리자 권한 요청 계정 조회
	@Override
	public List<UserVO> searchPreAccount() {
		try{
			return mapper.selectPreAccount();
		} catch (Exception e) {
			throw new ServiceException("관리자 권한 요청 계정 조회 실패", e);
		}
	}
	
	// 사용자 등급 변경 위한 계정 조회
	@Override
	public List<UserVO> searchAccount(String user_nm, String user_type) {
		try{
			return mapper.selectPreAccount();
		} catch (Exception e) {
			throw new ServiceException("관리자 권한 요청 계정 조회 실패", e);
		}
	}

	// 사용자 등급 변경
	@Override
	public boolean changeUserType(UserVO user) {
		try{
			int rows = mapper.updateUserType(user);
			return rows > 0;
		} catch (Exception e) {
			throw new ServiceException("관리자 권한 요청 계정 조회 실패", e);
		}
	}
}
