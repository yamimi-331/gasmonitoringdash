import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import matplotlib.ticker as ticker

df = pd.read_excel("data/GasData5.xlsx")
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

# 동계
winter_df = df[df['Month'].isin([11, 12, 1, 2, 3])]
seoul_df = df[df['Local'].isin(["서울특별시"])]

plt.figure(figsize=(10, 6))
sns.regplot(x='Temperature', y='GasSupply', data=df, ci=None, marker='o')
plt.title('기온 vs 가스 공급량 (월별)')
plt.xlabel('기온 (°C)')
plt.ylabel('가스 공급량')
corr_temp = df['Temperature'].corr(df['GasSupply'])
print(f"기온 vs 가스 공급량 상관계수: {corr_temp:.2f}")
plt.show()

sns.regplot(x='Humidity', y='GasSupply', data=df, ci=None, marker='o')
plt.title('습도 vs 가스 공급량 (월별)')
plt.xlabel('습도')
plt.ylabel('가스 공급량')
corr_humidity = df['Humidity'].corr(df['GasSupply'])
print(f"습도 vs 가스 공급량 상관계수: {corr_humidity:.2f}")
plt.show()

sns.regplot(x='Rainfall', y='GasSupply', data=df, ci=None, marker='o')
plt.title('강수량 vs 가스 공급량 (월별)')
plt.xlabel('강수량')
plt.ylabel('가스 공급량')
corr_humidity = df['Rainfall'].corr(df['GasSupply'])
print(f"강수량 vs 가스 공급량 상관계수: {corr_humidity:.2f}")
plt.show()

sns.regplot(data=seoul_df, x='Population', y='ResidentialGas', ci=None, marker='o')
plt.title('인구수 vs 가스 공급량')
plt.xlabel('인구수')
plt.ylabel('가스 공급량')
corr_pop = winter_df['Population'].corr(winter_df['ResidentialGas'])
print(f"인구수 vs 가정용 가스 공급량 상관계수: {corr_pop:.2f}")
plt.show()

# Y축 숫자 포맷: 천 단위 콤마 포함
ax = plt.gca()
ax.xaxis.set_major_formatter(ticker.FuncFormatter(lambda x, _: f'{x:,.0f}'))
ax.yaxis.set_major_formatter(ticker.FuncFormatter(lambda x, _: f'{x:,.0f}'))

# plt.tight_layout()
# plt.show()