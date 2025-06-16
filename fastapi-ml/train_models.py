import pandas as pd
import numpy as np
import joblib
import os

from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_squared_error, r2_score
from sklearn.preprocessing import MinMaxScaler

import xgboost as xgb
from prophet import Prophet
from keras.models import Sequential
from keras.layers import LSTM, Dense, Dropout
from keras.models import load_model

# 💾 데이터 로딩
df = pd.read_excel('./data/TotalData3.xlsx')  # 실제 엑셀 파일 경로에 맞게 수정
df['Date'] = pd.to_datetime(df['Date'])

# ✅ 날짜 숫자화
df['date_ordinal'] = df['Date'].map(pd.Timestamp.toordinal)

# ✅ 지역 인코딩 예시 (카테고리라면 필요)
if 'Local' in df.columns:
    df['Local_encoded'] = df['Local'].astype('category').cat.codes
else:
    df['Local_encoded'] = 0  # 없으면 0으로 대체

# ✅ XGBoost
X_xgb = df[['date_ordinal', 'Local_encoded', 'Temperature', 'Humidity', 'Population']]
y_xgb = df['GasSupply']

xgb_model = xgb.XGBRegressor(
    n_estimators=100,
    learning_rate=0.1,
    max_depth=5,
    random_state=42
)
xgb_model.fit(X_xgb, y_xgb)

# ✅ Prophet
prophet_df = df[['Date', 'GasSupply']].rename(columns={"Date": "ds", "GasSupply": "y"})
prophet_model = Prophet(yearly_seasonality=True, weekly_seasonality=False)
prophet_model.fit(prophet_df)

# ✅ LSTM 데이터 준비 함수
def prepare_lstm_data(df, seq_len=12):
    features = ['date_ordinal', 'Local_encoded', 'Temperature', 'Humidity', 'Population']
    scaler_X = MinMaxScaler()
    scaler_y = MinMaxScaler()
    
    X_scaled = scaler_X.fit_transform(df[features])
    y_scaled = scaler_y.fit_transform(df[['GasSupply']])
    
    X_seq, y_seq = [], []
    for i in range(seq_len, len(df)):
        X_seq.append(X_scaled[i-seq_len:i])
        y_seq.append(y_scaled[i])
    
    return np.array(X_seq), np.array(y_seq), scaler_X, scaler_y

X_lstm, y_lstm, scaler_X, scaler_y = prepare_lstm_data(df.copy())

# ✅ LSTM 모델 구성
lstm_model = Sequential([
    LSTM(50, activation='relu', input_shape=(X_lstm.shape[1], X_lstm.shape[2])),
    Dropout(0.2),
    Dense(1)
])
lstm_model.compile(optimizer='adam', loss='mse')
lstm_model.fit(X_lstm, y_lstm, epochs=50, batch_size=32, verbose=0)

# ✅ 모델 저장 폴더 준비
os.makedirs('models', exist_ok=True)

# ✅ 모델 저장
joblib.dump(xgb_model, 'models/xgb_model.pkl')
# ✅ Prophet 저장 (pickle로 대체)
import pickle
with open('models/prophet_model.pkl', 'wb') as f:
    pickle.dump(prophet_model, f)

lstm_model.save('models/lstm_model.h5')
joblib.dump(scaler_X, 'models/lstm_scaler_X.pkl')
joblib.dump(scaler_y, 'models/lstm_scaler_y.pkl')

print("✅ 모든 모델 저장 완료!")
