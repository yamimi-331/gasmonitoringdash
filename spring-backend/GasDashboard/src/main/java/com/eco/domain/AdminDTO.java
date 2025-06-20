package com.eco.domain;

import lombok.Data;

@Data
public class AdminDTO {
	private String user_cd;
	private String user_id;
	private String user_pw;
	private String user_nm;
	private String local_cd;
	private String user_addr;
	private char admin_yn;
	private char use_yn;
	
	private String local_nm;
	
	private String modal_year;
    private String modal_month;
    private Double usage_amount;

   
    private String usage_dt;
    private Integer usage_cd;
}
