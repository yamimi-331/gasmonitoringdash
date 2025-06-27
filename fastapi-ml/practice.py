import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import matplotlib.ticker as ticker

# 📁 데이터 불러오기 & 전처리
df = pd.read_excel("data/GasData5.xlsx")
plt.rcParams['font.family'] = 'Malgun Gothic'
plt.rcParams['axes.unicode_minus'] = False

# 🔢 숫자형 컬럼 처리
numeric_cols = ['GasSupply', 'ResidentialGas', 'Population']
for col in numeric_cols:
    df[col] = df[col].astype(str).str.replace(',', '').astype(float if col != 'Population' else int)

df['Temperature'] = df['Temperature'].astype(float)
df['Rainfall'] = df['Rainfall'].astype(float)
df['Humidity'] = df['Humidity'].astype(float)

# 📅 날짜 처리
df['Date'] = pd.to_datetime(df['Date'])
df['Month'] = df['Date'].dt.month
df['Year'] = df['Date'].dt.year

# ❄️ 동계 데이터
winter_df = df[df['Month'].isin([11, 12, 1, 2, 3])]

# 📊 공통 그래프 함수 (방정식 및 상관계수는 콘솔 출력용)
def plot_with_regression(x, y, data, title, xlabel, ylabel, logx=False):
    plt.figure(figsize=(10, 6))
    sns.regplot(x=x, y=y, data=data, ci=None, marker='o')
    
    if logx:
        plt.xscale('log')
    
    plt.title(title)
    plt.xlabel(xlabel)
    plt.ylabel(ylabel)
    
    ax = plt.gca()
    ax.xaxis.set_major_formatter(ticker.FuncFormatter(lambda x, _: f'{x:,.0f}'))
    ax.yaxis.set_major_formatter(ticker.FuncFormatter(lambda x, _: f'{x:,.0f}'))
    
    plt.grid(True)
    plt.tight_layout()
    plt.show()
    
    # 콘솔 출력으로 방정식, 상관계수 표시
    slope, intercept = np.polyfit(data[x], data[y], 1)
    corr = data[x].corr(data[y])
    print(f"{title}")
    print(f"  회귀방정식: y = {slope:.2f}x + {intercept:,.0f}")
    print(f"  상관계수 r = {corr:.2f}\n")

# 🔍 그래프 출력 및 콘솔 정보 출력
plot_with_regression('Temperature', 'GasSupply', df, '기온 vs 가스 공급량 (월별)', '기온 (°C)', '가스 공급량')
plot_with_regression('Humidity', 'GasSupply', df, '습도 vs 가스 공급량 (월별)', '습도', '가스 공급량')
plot_with_regression('Rainfall', 'GasSupply', df, '강수량 vs 가스 공급량 (월별)', '강수량', '가스 공급량')
plot_with_regression('Population', 'ResidentialGas', winter_df, '인구수 vs 가정용 가스 공급량 (동계)', '인구수', '가정용 가스 공급량', logx=True)
