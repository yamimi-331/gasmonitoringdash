import pandas as pd
import json

def yearSupply(df, year):
    # 연도 추출
    df['Year'] = pd.to_datetime(df['Date']).dt.year
    df['GasSupply'] = df['GasSupply'].replace(',', '', regex=True).astype(int)

    # 연도 필터링
    filtered = df[df['Year'] == year]

    # 연도, 지역별 공급량 총합 계산
    grouped = filtered.groupby(['Year', 'Local'])['GasSupply'].sum().reset_index()

    # json 저장
    result = {}
    for _, row in grouped.iterrows():
        year = str(row['Year'])
        local = row['Local']
        supply = row['GasSupply']

        if year not in result:
            result[year] = {}
        result[year][local] = supply

    # 공급량 기준 정렬
    for year in result:
        sorted_local = dict(sorted(result[year].items(), key=lambda item: item[1], reverse=True))
        result[year] = sorted_local

    # year_supply = json.dumps(result, indent=4, ensure_ascii=False)
    return result