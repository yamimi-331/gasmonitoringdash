package com.eco.domain;

import lombok.Data;

@Data
public class UsageVO {
	private int usage_cd;
	private char user_cd;
	private char local_cd;
	private char usage_dt;
	private int usage_amount;
	private char use_yn;	
}
