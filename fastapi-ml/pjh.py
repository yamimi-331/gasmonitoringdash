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

# 한글 폰트 설정
plt.rcParams['font.family'] = 'Gulim'

def load_and_preprocess_data():
    # 데이터 로드
    df = pd.read_excel("./data/TotalData3.xlsx")
    
    # 결측치 처리
    df.fillna(0, inplace=True)

    df['Date'] = pd.to_datetime(df['Date'])  # 엑셀에서 날짜로 합친 경우
    df = df.sort_values('Date')
    
    return df

def get_local_result(selected_local=None):
    print(f"Input selected_local: {selected_local}")
    df = load_and_preprocess_data()
    
    region_mapping = {"서울": "서울특별시", "경기도": "경기도"}
    selected_code = None
    if selected_local:
        selected_code = region_mapping.get(selected_local)
        print(f"Mapped code: {selected_code}")
        if selected_code:
            df = df[df['Local'] == selected_code]
        else:
            return {"error": f"지역 '{selected_local}'에 대한 데이터가 없습니다."}

    print(f"Filtered data shape: {df.shape}")
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
    
    img_base64 = base64.b64encode(buf.read()).decode('utf-8')
    
    return {"chartImage": img_base64,
            "selected_local": selected_local}