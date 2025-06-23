package com.eco.service;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

import org.springframework.stereotype.Service;

import com.eco.domain.LocalVO;
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
			String localCode = String.valueOf(user.getLocal_cd());  // 회원가입 폼에서 선택한 지역코드
		    String userCd = findMaxUserCd(localCode);
		    user.setUser_cd(userCd);
			mapper.userInsert(user);
		} catch (Exception e) {
			throw new ServiceException("회원가입 실패", e);
		}
	}
		
	// 사용자 ID로 사용자 CD 반환
	@Override
	public UserVO findByUserId(String user_id) {
		try {
			return mapper.selectCdDataByUserId(user_id);
		} catch (Exception e) {
			throw new ServiceException("사용자 조회 실패", e);
		}
	}
	
	//cd값 찾아서 다음 cd 만들기
	@Override
	public String findMaxUserCd(String localCode) {
		try {
			String year = new SimpleDateFormat("yyyy").format(new Date());

	        int maxSeq = mapper.selectMaxUserCd(year);
	        int nextSeq = maxSeq + 1;
	        String seqStr = String.format("%04d", nextSeq);  // 4자리 0패딩
	
	        return year + localCode + seqStr;
		} catch(Exception e) {
			throw new ServiceException("user_cd 생성 실패", e);
		}
		
	}	
	
	//지역코드 가져오기
	@Override
	public List<LocalVO> getLocalList(){
		try {
			return mapper.selectLocalList();
		} catch(Exception e) {
			throw new ServiceException("지역코드 가져오기 실패", e);
		}
		
	}

	@Override
	public int updateUserInfo(UserVO sessionUser) {
		try {
			int updatedRows = mapper.updateUserInfo(sessionUser);
			
			return updatedRows;
		} catch(Exception e) {
			throw new ServiceException("회원정보 수정 실패", e);
		}
	}


}
