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
from sklearn.preprocessing import LabelEncoder, MinMaxScaler # MinMaxScaler 추가
import io
import base64
import warnings
warnings.filterwarnings('ignore')

# 한글 폰트 설정
plt.rcParams['font.family'] = 'Gulim'

df = pd.read_excel("./data/TotalData3.xlsx")  

def get_total_supply_by_region_2025():
    # '2025년' 데이터만 필터링
    df['Date'] = pd.to_datetime(df['Date'])  # 날짜 형식 통일
    df_2025 = df[df['Date'].dt.year == 2025]

    # 지역별 공급량 합계 계산
    region_supply = df_2025.groupby('Local')['GasSupply'].sum().reset_index()
    region_supply.columns = ['Local', 'total_supply']

    return region_supply.to_dict(orient="records")  # JSON 형태로 반환