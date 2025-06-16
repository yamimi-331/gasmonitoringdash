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

def create_visualizations(df, selected_local = None):
    visualizations = {}
    
    # 지역 선택: 전체 or 특정 지역
    if selected_local:
        region_mapping = {"서울": "R02", "경기도": "R04"}
        selected_code = region_mapping.get(selected_local)
        df = df[df['Local'] == selected_code]
        if df.empty:
            print(f"선택한 지역 '{selected_local}'에 대한 데이터가 없습니다.")
            return visualizations  # 빈 결과 반환
    
    # 월별 평균 가스 공급량 추이
    plt.figure(figsize=(12, 6))
    df['Month'] = df['Date'].dt.month  # date에서 월 정보 추출
    monthly_avg = df.groupby('Month')['GasSupply'].mean()
    sns.lineplot(x=monthly_avg.index, y=monthly_avg.values)
    plt.title(f'[{selected_local}] 월별 평균 가스 공급량 추이' if selected_local else '월별 평균 가스 공급량 추이')
    plt.xlabel('월')
    plt.ylabel('평균 가스 공급량')
    buf = io.BytesIO()
    plt.savefig(buf, format='png')
    plt.close()
    buf.seek(0)
    visualizations['monthly_trend2'] = base64.b64encode(buf.read()).decode('utf-8')

    return visualizations

def get_prediction_results():
    df = load_and_preprocess_data()
    
    # 지역 리스트 가져오기 (중복 제거, 정렬)
    region_list = sorted(["서울", "경기도"])
    selected_local = st.selectbox("지역 선택", ["전체"] + region_list)
    
    # 전체 선택 시 None 전달
    if selected_local == "전체":
        selected_local = None
    
    # 시각화 생성
    visualizations = create_visualizations(df, selected_local)
    
    # 이미지 출력
    if 'monthly_trend2' in visualizations:
        img_data = visualizations['monthly_trend2']
        st.image(base64.b64decode(img_data))