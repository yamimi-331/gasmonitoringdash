package com.eco.service;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
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
public class UserServiceImpl implements UserService {
	// MySQL 쿼리 매핑
	private UserMapper mapper;
	// 비밀번호 암호화
	private BCryptPasswordEncoder passwordEncoder;
	
	// 로그인
	@Override
	public UserVO login(UserVO inputUser) {
		try {
	        // 입력한 아이디로 사용자 정보 조회
	        UserVO dbUser = mapper.getUserSelect(inputUser); // 이 때 inputUser.user_id 가 기준
	        if (dbUser != null && passwordEncoder.matches(inputUser.getUser_pw(), dbUser.getUser_pw())) {
	            return dbUser; // 로그인 성공
	        }
	        return null; // 로그인 실패
	    } catch (Exception e) {
	        throw new ServiceException("로그인 실패", e);
	    }
	}

	// 회원가입
	@Override
	public void signup(UserVO user) {
		try {
			String localCode = String.valueOf(user.getLocal_cd()); // 회원가입 폼에서 선택한 지역코드
			String userCd = findMaxUserCd(localCode);
			user.setUser_cd(userCd);
			// 비밀번호 암호화
			String encodedPw = passwordEncoder.encode(user.getUser_pw());
	        user.setUser_pw(encodedPw);
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

	// cd값 찾아서 다음 cd 만들기
	@Override
	public String findMaxUserCd(String localCode) {
		try {
			String year = new SimpleDateFormat("yyyy").format(new Date());

			int maxSeq = mapper.selectMaxUserCd(year);
			int nextSeq = maxSeq + 1;
			String seqStr = String.format("%04d", nextSeq); // 4자리 0패딩

			return year + localCode + seqStr;
		} catch (Exception e) {
			throw new ServiceException("user_cd 생성 실패", e);
		}

	}

	// 지역코드 가져오기
	@Override
	public List<LocalVO> getLocalList() {
		try {
			return mapper.selectLocalList();
		} catch (Exception e) {
			throw new ServiceException("지역코드 가져오기 실패", e);
		}

	}

	// 회원정보 수정
	@Override
	public void updateUserInfo(UserVO sessionUser) {
		try {
			int updatedRows = mapper.updateUserInfo(sessionUser);
			if (updatedRows == 0) {
				throw new ServiceException("회원정보 수정 실패: 해당 사용자가 없습니다.");
			}
		} catch (Exception e) {
			throw new ServiceException("회원정보 수정 실패", e);
		}
	}

	// 회원 탈퇴
	@Override
	public void deactivateUser(String user_cd) {
		try {
			int updatedRows = mapper.deactivateUser(user_cd);
			if (updatedRows == 0) {
				throw new ServiceException("해당 사용자를 찾을 수 없습니다.");
			}
		} catch (Exception e) {
			throw new ServiceException("회원 탈퇴 처리 실패", e);
		}
	}
	
}
