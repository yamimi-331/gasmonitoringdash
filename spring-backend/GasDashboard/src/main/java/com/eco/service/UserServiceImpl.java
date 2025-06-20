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
	
	//지역코드 가져오기
	@Override
	public List<LocalVO> getLocalList(){
		return mapper.selectLocalList();
	}
	
	//cd값 찾아서 다음 cd 만들기
	@Override
	public String findMaxUserCd(String localCode) {
		String year = new SimpleDateFormat("yyyy").format(new Date());

        int maxSeq = mapper.findMaxUserCd(year);
        int nextSeq = maxSeq + 1;
        String seqStr = String.format("%04d", nextSeq);  // 4자리 0패딩

        return year + localCode + seqStr;
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
	public boolean findByUserId(String user_id) {
		try {
			String result = mapper.selectUserCdByUserId(user_id);
			return result != null;
		} catch (Exception e) {
			throw new ServiceException("사용자 조회 실패", e);
		}
	}



}
