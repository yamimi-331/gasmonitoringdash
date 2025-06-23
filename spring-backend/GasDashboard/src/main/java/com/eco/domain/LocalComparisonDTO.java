package com.eco.domain;

import lombok.Data;

@Data
public class LocalComparisonDTO {
	// 지역명(LocalVO)
    private String localNm;

    // 지역 당월 사용량 평균(PublicVO)
    private float avgCurrentMonthPublicUsage; 

    // 당월 사용량 (UsageVO)
    private float currentMonthUsage;

    // 전년 동월 사용량 (UsageVO)
    private float lastYearSameMonthUsage;

    // 연간 평균 사용량 (UsageVO)
    private float yearlyAvgUsage;
}
