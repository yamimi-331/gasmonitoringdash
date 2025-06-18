# train_model.py
import pandas as pd
from prophet import Prophet
import joblib

# 1. CSV 로드 및 월 단위 집계
df = pd.read_excel("./data/GasData.xlsx")
df['Date'] = pd.to_datetime(df['Date'], format="%m/%d/%y")
df['YearMonth'] = df['Date'].dt.to_period("M").dt.to_timestamp()
monthly = df.groupby('YearMonth').agg({'GasSupply': 'sum'}).reset_index()
monthly.columns = ['ds', 'y']  # Prophet 형식

# 2. Prophet 모델 학습
model = Prophet()
model.fit(monthly)

# 3. 모델 저장
joblib.dump(model, "./models/model_prophet.pkl")
print("✅ 모델 학습 및 저장 완료")
