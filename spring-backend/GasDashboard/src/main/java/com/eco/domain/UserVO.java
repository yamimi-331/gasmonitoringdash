package com.eco.domain;

import lombok.Data;

@Data
public class UserVO {
	private char userCd;
	private String userId;
	private String userPw;
	private String userNm;
	private char localCd;
	private String userAddr;
	private char adminYn;
	private char useYn;
}
