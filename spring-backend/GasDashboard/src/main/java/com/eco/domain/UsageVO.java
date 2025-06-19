package com.eco.domain;

import lombok.Data;

@Data
public class UsageVO {
	private int usage_cd;
	private String user_cd;
	private String local_cd;
	private String usage_dt;
	private int usage_amount;
	private char use_yn;	
}
