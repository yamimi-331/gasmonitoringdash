import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import matplotlib.ticker as ticker

df = pd.read_excel("data/GasData.xlsx")
plt.rcParams['font.family'] = 'Malgun Gothic'
plt.rcParams['axes.unicode_minus'] = False

# 숫자형 데이터 변환 (쉼표 제거)
df['GasSupply'] = df['GasSupply'].astype(str).str.replace(',', '').astype(float)
df['ResidentialGas'] = df['ResidentialGas'].astype(str).str.replace(',', '').astype(float)

df['Temperature'] = df['Temperature'].astype(float)
df['Population'] = df['Population'].astype(str).str.replace(',', '').astype(int)

# 날짜 파싱
df['Date'] = pd.to_datetime(df['Date'])
df['Month'] = df['Date'].dt.month
df['Year'] = df['Date'].dt.year

plt.figure(figsize=(10, 6))
sns.regplot(x='Temperature', y='GasSupply', data=df, ci=None, marker='o')
plt.title('기온 vs 가스 공급량 (월별)')
plt.xlabel('기온 (°C)')
plt.ylabel('가스 공급량')
corr_temp = df['Temperature'].corr(df['GasSupply'])
print(f"기온 vs 가스 공급량 상관계수: {corr_temp:.2f}")

# sns.regplot(x='Humidity', y='GasSupply', data=df, ci=None, marker='o')
# plt.title('습도 vs 가스 공급량 (월별)')
# plt.xlabel('습도')
# plt.ylabel('가스 공급량')
corr_humidity = df['Humidity'].corr(df['GasSupply'])
print(f"습도 vs 가스 공급량 상관계수: {corr_humidity:.2f}")

cold_df = df[df['ColdDay'] > 0]
# sns.regplot(x='ColdDay', y='GasSupply', data=cold_df, ci=None, marker='o')
# plt.title('한파일수 vs 가스 공급량')
# plt.xlabel('한파일수')
# plt.ylabel('가스 공급량')
corr_cold = cold_df['ColdDay'].corr(cold_df['ResidentialGas'])
print(f"한파일수 vs 가스 공급량 상관계수: {corr_cold:.2f}")
spearman_corr = cold_df['ColdDay'].corr(cold_df['ResidentialGas'], method='spearman')
print(f"스피어만 상관계수: {spearman_corr:.2f}")

winter_df = df[df['Month'].isin([11, 12, 1, 2, 3])]
# sns.regplot(data=winter_df, x='Population', y='GasSupply', ci=None, marker='o')
# plt.title('인구수 vs 가스 공급량')
# plt.xlabel('인구수')
# plt.ylabel('가스 공급량')
corr_pop = winter_df['Population'].corr(winter_df['GasSupply'])
print(f"인구수 vs 가정용 가스 공급량 상관계수: {corr_pop:.2f}")

# Y축 숫자 포맷: 천 단위 콤마 포함
ax = plt.gca()
ax.xaxis.set_major_formatter(ticker.FuncFormatter(lambda x, _: f'{x:,.0f}'))
ax.yaxis.set_major_formatter(ticker.FuncFormatter(lambda x, _: f'{x:,.0f}'))

plt.tight_layout()
plt.show()