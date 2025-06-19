package com.eco.domain;

import lombok.Data;

@Data
public class UsageVO {
	private int usageCd;
	private char userCd;
	private char localCd;
	private char usageDt;
	private int usageAmount;
	private char useYn;	
}
