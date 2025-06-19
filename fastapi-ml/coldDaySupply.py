import pandas as pd
import json

def get_winter_gas_data(df, region, year):
    """
    특정 지역과 연도에 대해 월별(1, 2, 3, 11, 12월) 동계한파일수와 가스사용량을 JSON으로 반환
    Args:
        df (dataframe): 엑셀 파일 
        region (str): 지역명 (예: '강원특별자치도')
        year (int): 연도 (예: 2020)
    Returns:
        str: JSON 형식 문자열
    """
    
    # 날짜 컬럼 파싱
    df['Date'] = pd.to_datetime(df['Date'])

    # 연도, 지역, 월 필터링
    df_filtered = df[
        (df['Date'].dt.year == year) &
        (df['Local'] == region) &
        (df['Date'].dt.month.isin([1, 2, 3, 11, 12]))
    ]

    if df_filtered.empty:
        return json.dumps({"message": "해당 조건의 데이터가 없습니다."}, ensure_ascii=False)

    # 필요한 컬럼만 정리
    df_filtered['Month'] = df_filtered['Date'].dt.month
    result = df_filtered[['Month', 'ColdDay', 'GasSupply']].sort_values(by='Month')

    return result.to_dict(orient="records")


# ✅ 테스트 실행
# if __name__ == "__main__":
#     file_path = "./data/GasData.xlsx"  # 파일명 바꿔주세요
#     region = "강원특별자치도"
#     year = 2021

#     output_json = get_winter_gas_data(file_path, region, year)
#     print(output_json)
