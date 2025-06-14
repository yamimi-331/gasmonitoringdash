import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LinearRegression
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_squared_error, r2_score
import xgboost as xgb
from prophet import Prophet
import tensorflow as tf
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import LSTM, Dense, Dropout
import io
import base64
import warnings
warnings.filterwarnings('ignore')

# 한글 폰트 설정
plt.rcParams['font.family'] = 'Gulim'

def load_and_preprocess_data():
    """
    데이터 로드 및 전처리 함수
    - 결측치 처리
    - 지역 코드 변환
    - 시계열 데이터 정렬
    """
    # 데이터 로드
    df = pd.read_excel("./data/GasData.xlsx")
    
    # 결측치 처리
    df.fillna(0, inplace=True)
    
    # 지역 코드를 숫자로 변환 (R01~R17)
    region_mapping = {f'R{i:02d}': i for i in range(1, 18)}
    df['Local'] = df['Local'].map(region_mapping)
    
    # 날짜 컬럼 생성 및 정렬
    df['date'] = pd.to_datetime(df[['Year', 'Month']].assign(day=1))
    df = df.sort_values('date')
    
    return df

def prepare_time_series_data(df):
    """
    시계열 데이터 준비
    - Prophet 모델용 데이터프레임 생성
    - LSTM 모델용 시퀀스 데이터 생성
    """
    # Prophet용 데이터 준비
    prophet_df = df.groupby('date')['gas_supply_amount'].sum().reset_index()
    prophet_df.columns = ['ds', 'y']
    
    # LSTM용 데이터 준비
    sequence_length = 12  # 12개월 시퀀스
    X_lstm = []
    y_lstm = []
    
    for region in df['Local'].unique():
        region_data = df[df['Local'] == region]
        for i in range(len(region_data) - sequence_length):
            X_lstm.append(region_data[['temperature', 'humidity', 'num_occupants']].iloc[i:i+sequence_length].values)
            y_lstm.append(region_data['gas_supply_amount'].iloc[i+sequence_length])
    
    return prophet_df, np.array(X_lstm), np.array(y_lstm)

def train_models(df):
    """
    다양한 모델 학습
    - XGBoost: 지역별 특성과 기온, 습도 등을 고려한 예측
    - Prophet: 시계열 특성을 고려한 예측
    - LSTM: 시계열 패턴 학습
    """
    # XGBoost 모델 학습
    X = df[['Year', 'Month', 'Local', 'temperature', 'humidity', 'num_occupants']]
    y = df['gas_supply_amount']
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
    
    xgb_model = xgb.XGBRegressor(
        n_estimators=100,
        learning_rate=0.1,
        max_depth=5,
        random_state=42
    )
    xgb_model.fit(X_train, y_train)
    xgb_pred = xgb_model.predict(X_test)
    
    # Prophet 모델 학습
    prophet_df, X_lstm, y_lstm = prepare_time_series_data(df)
    prophet_model = Prophet(yearly_seasonality=True, weekly_seasonality=False)
    prophet_model.fit(prophet_df)
    
    # LSTM 모델 학습
    lstm_model = Sequential([
        LSTM(50, activation='relu', input_shape=(X_lstm.shape[1], X_lstm.shape[2])),
        Dropout(0.2),
        Dense(1)
    ])
    lstm_model.compile(optimizer='adam', loss='mse')
    lstm_model.fit(X_lstm, y_lstm, epochs=50, batch_size=32, verbose=0)
    
    # 모델 평가
    results = {
        'XGBoost': {
            'model': xgb_model,
            'mse': mean_squared_error(y_test, xgb_pred),
            'rmse': np.sqrt(mean_squared_error(y_test, xgb_pred)),
            'r2': r2_score(y_test, xgb_pred)
        },
        'Prophet': {
            'model': prophet_model
        },
        'LSTM': {
            'model': lstm_model
        }
    }
    
    return results, X_test, y_test

def create_visualizations(df, results, X_test, y_test):
    """
    다양한 시각화 생성
    - 월별 평균 가스 공급량 추이
    - 온도와 가스 공급량의 관계
    - 지역별 가스 공급량 패턴
    - 모델별 예측 결과 비교
    """
    visualizations = {}
    
    # 1. 월별 평균 가스 공급량 추이
    plt.figure(figsize=(12, 6))
    monthly_avg = df.groupby('Month')['gas_supply_amount'].mean()
    sns.lineplot(x=monthly_avg.index, y=monthly_avg.values)
    plt.title('월별 평균 가스 공급량 추이')
    plt.xlabel('월')
    plt.ylabel('평균 가스 공급량')
    buf = io.BytesIO()
    plt.savefig(buf, format='png')
    plt.close()
    buf.seek(0)
    visualizations['monthly_trend'] = base64.b64encode(buf.read()).decode('utf-8')
    
    # 2. 온도와 가스 공급량의 관계
    plt.figure(figsize=(12, 6))
    sns.scatterplot(data=df, x='temperature', y='gas_supply_amount', hue='Local')
    plt.title('온도와 가스 공급량의 관계 (지역별)')
    plt.xlabel('온도')
    plt.ylabel('가스 공급량')
    buf = io.BytesIO()
    plt.savefig(buf, format='png')
    plt.close()
    buf.seek(0)
    visualizations['temp_supply'] = base64.b64encode(buf.read()).decode('utf-8')
    
    # 3. 지역별 가스 공급량 패턴
    plt.figure(figsize=(12, 6))
    sns.boxplot(data=df, x='Local', y='gas_supply_amount')
    plt.title('지역별 가스 공급량 분포')
    plt.xlabel('지역 코드')
    plt.ylabel('가스 공급량')
    buf = io.BytesIO()
    plt.savefig(buf, format='png')
    plt.close()
    buf.seek(0)
    visualizations['regional_pattern'] = base64.b64encode(buf.read()).decode('utf-8')
    
    # 4. XGBoost 모델 예측 결과
    plt.figure(figsize=(12, 6))
    y_pred = results['XGBoost']['model'].predict(X_test)
    plt.scatter(y_test, y_pred, alpha=0.5)
    plt.plot([y_test.min(), y_test.max()], [y_test.min(), y_test.max()], 'r--', lw=2)
    plt.title('XGBoost 모델: 실제값 vs 예측값')
    plt.xlabel('실제 가스 공급량')
    plt.ylabel('예측 가스 공급량')
    buf = io.BytesIO()
    plt.savefig(buf, format='png')
    plt.close()
    buf.seek(0)
    visualizations['prediction_comparison'] = base64.b64encode(buf.read()).decode('utf-8')
    
    return visualizations

def get_prediction_results():
    """
    최종 예측 결과 반환
    - 데이터 전처리
    - 모델 학습
    - 시각화 생성
    """
    # 데이터 로드 및 전처리
    df = load_and_preprocess_data()
    
    # 모델 학습
    results, X_test, y_test = train_models(df)
    
    # 시각화 생성
    visualizations = create_visualizations(df, results, X_test, y_test)
    
    # 결과 반환
    return {
        'models': {
            name: {
                'mse': result.get('mse', None),
                'rmse': result.get('rmse', None),
                'r2': result.get('r2', None)
            }
            for name, result in results.items()
        },
        'visualizations': visualizations
    } 