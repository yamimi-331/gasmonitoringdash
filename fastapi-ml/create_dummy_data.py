import pandas as pd
import numpy as np
from datetime import datetime
import os

# 데이터 폴더 생성
if not os.path.exists('data'):
    os.makedirs('data')

# 기본 설정
years = range(2020, 2025)  # 2020년부터 2024년까지
months = range(1, 13)      # 1월부터 12월까지
regions = [f'R{i:02d}' for i in range(1, 18)]  # R01부터 R17까지

# 더미 데이터 생성
data = []

for year in years:
    for month in months:
        for region in regions:
            # 계절성을 고려한 온도 생성 (겨울철에 낮은 온도)
            if month in [12, 1, 2]:  # 겨울
                temperature = np.random.normal(-5, 5)
            elif month in [3, 4, 5]:  # 봄
                temperature = np.random.normal(10, 5)
            elif month in [6, 7, 8]:  # 여름
                temperature = np.random.normal(25, 5)
            else:  # 가을
                temperature = np.random.normal(15, 5)
            
            # 습도 생성 (0-100 사이)
            humidity = np.random.normal(60, 15)
            humidity = max(0, min(100, humidity))
            
            # 거주자 수 생성 (지역별 차이)
            base_occupants = 1000000  # 기본 100만명
            region_factor = int(region[1:]) * 50000  # 지역별 차이
            num_occupants = base_occupants + region_factor + np.random.normal(0, 50000)
            num_occupants = max(0, int(num_occupants))
            
            # 가스 공급량 생성 (온도와 계절성 고려)
            base_supply = 10000  # 기본 공급량
            temp_factor = -temperature * 100  # 온도가 낮을수록 공급량 증가
            season_factor = 0
            if month in [12, 1, 2]:  # 겨울
                season_factor = 5000
            elif month in [6, 7, 8]:  # 여름
                season_factor = -2000
            
            gas_supply = base_supply + temp_factor + season_factor + np.random.normal(0, 1000)
            gas_supply = max(0, int(gas_supply))
            
            data.append({
                'Year': year,
                'Month': month,
                'Local': region,
                'temperature': round(temperature, 1),
                'humidity': round(humidity, 1),
                'num_occupants': num_occupants,
                'gas_supply_amount': gas_supply
            })

# DataFrame 생성
df = pd.DataFrame(data)

# 데이터 정렬
df = df.sort_values(['Year', 'Month', 'Local'])

# Excel 파일로 저장
df.to_excel('./data/GasData.xlsx', index=False)

print("더미 데이터가 생성되었습니다.")
print(f"총 데이터 수: {len(df)}")
print("\n데이터 미리보기:")
print(df.head())
print("\n기본 통계:")
print(df.describe()) 