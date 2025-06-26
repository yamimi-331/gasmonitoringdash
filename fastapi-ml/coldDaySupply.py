import pandas as pd
import json

# def get_winter_gas_data(df, region, year):
#     """
#     특정 지역과 연도에 대해 월별(1, 2, 3, 11, 12월) 동계한파일수와 가스사용량을 JSON으로 반환
#     Args:
#         df (dataframe): 엑셀 파일 
#         region (str): 지역명 (예: '강원특별자치도')
#         year (int): 연도 (예: 2020)
#     Returns:
#         str: JSON 형식 문자열
#     """
    
#     # 날짜 컬럼 파싱
#     df['Date'] = pd.to_datetime(df['Date'])

#     # 연도, 지역, 월 필터링
#     df_filtered = df[
#         (df['Date'].dt.year == year) &
#         (df['Local'] == region) &
#         (df['Date'].dt.month.isin([1, 2, 3, 11, 12]))
#     ]

#     if df_filtered.empty:
#         return json.dumps({"message": "해당 조건의 데이터가 없습니다."}, ensure_ascii=False)

#     # 필요한 컬럼만 정리
#     df_filtered['Month'] = df_filtered['Date'].dt.month
#     result = df_filtered[['Month', 'ColdDay', 'GasSupply']].sort_values(by='Month')

#     return result.to_dict(orient="records")


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

    # 지역 필터링
    df_region = df[df['Local'] == region].copy()
    
    # 연도-월 필터링
    prev_year = year - 1
    
    # 11월~12월 (전년도), 1월~3월 (현재년도)
    df_winter = df_region[
        ((df_region['Date'].dt.year == prev_year) & (df_region['Date'].dt.month.isin([11, 12]))) |
        ((df_region['Date'].dt.year == year) & (df_region['Date'].dt.month.isin([1, 2, 3])))
    ]

    if df_winter.empty:
        return json.dumps({"message": "해당 조건의 데이터가 없습니다."}, ensure_ascii=False)

    df_winter['YearMonth'] = df_winter['Date'].dt.to_period('M').astype(str)
    
    # 월별 데이터가 1개이므로 그냥 정렬만 해주면 됨
    df_winter_sorted = df_winter.sort_values(by='YearMonth')

    # 필요한 컬럼만 JSON에 포함
    result = df_winter_sorted[['YearMonth', 'ColdDay', 'GasSupply', 'Temperature']].to_dict(orient='records')

    return result

# ✅ 테스트 실행
# if __name__ == "__main__":
#     file_path = "./data/GasData.xlsx"  # 파일명 바꿔주세요
#     region = "강원특별자치도"
#     year = 2021

#     output_json = get_winter_gas_data(file_path, region, year)
#     print(output_json)
