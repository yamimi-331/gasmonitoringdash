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
from sklearn.preprocessing import LabelEncoder
import io
import base64
import warnings
warnings.filterwarnings('ignore')
import streamlit as st
from shj import load_and_preprocess_data, train_models, plot_supply_prediction_timeline, plot_prophet_prediction, predict_lstm_future, plot_lstm_prediction


# 한글 폰트 설정
plt.rcParams['font.family'] = 'Gulim'

def get_local_result(selected_local=None, selected_model=None, period=3):
    df = load_and_preprocess_data()
    
    region_mapping = {"서울": "서울특별시", "인천": "인천광역시", "경기": "경기도", "부산": "부산광역시", 
                      "대구": "대구광역시", "광주": "광주광역시", "대전": "대전광역시", "울산": "울산광역시", 
                      "세종": "세종특별자치시", "강원": "강원특별자치도", "충북": "충청북도", "충남": "충청남도", 
                      "전북": "전북특별자치도", "전남": "전라남도", "경북": "경상북도", "경남": "경상남도", 
                      "제주": "제주특별자치도", "전국": "전국"}
    selected_code = region_mapping.get(selected_local)
    if selected_local and selected_code:
        df = df[df['Local'] == selected_code]
    elif selected_local and not selected_code:
        return {"error": f"지역 '{selected_local}'에 대한 데이터가 없습니다."}

    if df.empty:
        return {"error": f"'{selected_local}' 지역에 대한 데이터가 없습니다."}

    plt.figure(figsize=(10, 5))
    df['Month'] = df['Date'].dt.month
    monthly_avg = df.groupby('Month')['GasSupply'].mean()
    sns.lineplot(x=monthly_avg.index, y=monthly_avg.values)
    plt.title(f"{selected_local} 월별 평균 가스 공급량 추이")
    plt.xlabel("월")
    plt.ylabel("평균 가스 공급량")
    buf = io.BytesIO()
    plt.savefig(buf, format='png')
    plt.close()
    buf.seek(0)
    local_chart = base64.b64encode(buf.read()).decode('utf-8')

    full_df = load_and_preprocess_data()
    results = train_models(full_df)

    if selected_model == "XGBoost":
        end_date = (pd.to_datetime('2025-03-01') + pd.DateOffset(months=period)).strftime('%Y-%m-%d')
        model_chart = plot_supply_prediction_timeline(df, results, start_date='2024-01-01', end_date=end_date)

    elif selected_model == "Prophet":
        prophet_model = results['Prophet']['model']
        prophet_df = results['Prophet']['prophet_df']
        model_chart = plot_prophet_prediction(prophet_model, prophet_df, forecast_periods=period)

    elif selected_model == "LSTM":
        lstm_model = results['LSTM']['model']
        original_df = results['LSTM']['original_df']
        scaler_X = results['LSTM']['scaler_X']
        scaler_y = results['LSTM']['scaler_y']
        sequence_len = results['LSTM']['sequence_length']

        if selected_code:
            from sklearn.preprocessing import LabelEncoder
            le = LabelEncoder()
            original_df['Local_encoded'] = le.fit_transform(original_df['Local'])
            target_code = le.transform([selected_code])[0]
        else:
            target_code = None  # 전국

        pred_df = predict_lstm_future(lstm_model, original_df, scaler_X, scaler_y, sequence_len, forecast_periods=period, target_region_encoded=target_code)
        model_chart = plot_lstm_prediction(original_df, pred_df, forecast_periods=period)

    else:
        return {"error": f"'{selected_model}' 분석 모델은 지원되지 않습니다."}

    return {"localChartImage": local_chart,
            "modelChartImage": model_chart,
            "selected_local": selected_local,
            "selected_model": selected_model}