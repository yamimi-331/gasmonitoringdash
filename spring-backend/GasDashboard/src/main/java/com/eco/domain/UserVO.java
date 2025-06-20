package com.eco.domain;

import lombok.Data;

@Data
public class UserVO {
	private String user_cd;
	private String user_id;
	private String user_pw;
	private String user_nm;
	private String local_cd;
	private String user_addr;
	private String user_type;
	private char use_yn;
}
