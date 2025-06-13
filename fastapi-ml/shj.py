import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

plt.rcParams['font.family'] = 'Gulim'
import warnings
warnings.filterwarnings('ignore')

xls = pd.read_excel("./data/GasSupplyData.xlsx", sheet_name=None)

# 각 시트별 데이터프레임을 리스트로 저장
df_list = []

for sheet_name, df in xls.items():
    df['Year'] = int(sheet_name)  # 시트명이 '2020', '2021' 이런 식이라고 가정
    df.fillna(0, inplace=True)
    df_list.append(df)

# 하나로 합치기
df_all = pd.concat(df_list, ignore_index=True)

df_all.fillna(0, inplace=True)
# df.replace({'지역':{'전국':0, '서울':1, '인천':2, '경기':3, '부산':4, '대구':5, '광주':6,
#                   '대전':7, '울산':8, '세종':9, '강원':10, '충북':11, '충남':12, '전북':13,
#                   '전남':14, '경북':15, '경남':16, '제주':17,}}, inplace=True)

df_seoul = df_all[df_all['Local'] == '서울']
sns.barplot(x='Month', y='Supply', hue='Local', data=df[df['Local'] == '서울'])
plt.show()


df2=pd.read_excel("기상청 전처리 데이터.xlsx", sheet_name='서울_전처리')
df2.fillna(0, inplace=True)

df2_2023 = df2[df2['년'] == 2023]
# sns.barplot(x='월', y='평균기온', data=df2_2023)
# plt.show()

# 월별로 정렬 (혹시 월 순서가 안 맞을 때 대비)
df_seoul = df_seoul.sort_values('Month')
df2_2023 = df2_2023.sort_values('월')

# 필요한 컬럼만 뽑아서 데이터프레임 만들기
merged = pd.merge(df_seoul[['Year', 'Supply']],
                  df2_2023[['월', '평균기온']],
                  on='월')

# 상관계수 계산 (피어슨)
correlation = merged['공급량'].corr(merged['평균기온'])
# print(f"공급량과 평균기온 간 상관계수: {correlation:.3f}")

# 그래프
sns.lmplot(x='평균기온', y='공급량', data=merged)
plt.title('서울시 2023년 평균기온과 가스 공급량 산점도')
plt.show()

