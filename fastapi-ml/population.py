import pandas as pd
import json

df = pd.read_excel("./data/GasData.xlsx")

# 연도 추출
df['Year'] = pd.to_datetime(df['Date']).dt.year
df['GasSupply'] = df['GasSupply'].replace(',', '', regex=True).astype(int)
df['Population'] = df['Population'].replace(',', '', regex=True).astype(int)

# 지역 필터링
selected_local = "경기도"
local = df[df['Local'] == selected_local]

# 연도, 지역별 공급량 총합 계산
gasSupply = df.groupby('Year')['GasSupply'].sum().reset_index()
# 연도, 지역별 인구수 평균 계산
population = df.groupby('Year')['Population'].mean().reset_index()

merged = pd.merge(gasSupply, population, on='Year')

# json 저장
result = {selected_local: {}}
for _, row in merged.iterrows():
    year = str(int(row['Year']))
    population = int(row['Population'])
    gas_supply = int(row['GasSupply'])

    result[selected_local][year] = {"평균 인구수": population,
                                    "가스 총 공급량": gas_supply,
                                    "1인당 가스 사용량": round(gas_supply / population, 4)}

year_supply = json.dumps(result, indent=4, ensure_ascii=False)
print(year_supply)