package com.eco.domain;

import lombok.Data;

@Data
public class UserVO {
	private char user_cd;
	private String user_id;
	private String user_pw;
	private String user_nm;
	private char local_cd;
	private String user_addr;
	private char admin_yn;
	private char use_yn;
}
