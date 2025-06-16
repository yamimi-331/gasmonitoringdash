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
from sklearn.preprocessing import LabelEncoder, MinMaxScaler
import io
import base64
import warnings
warnings.filterwarnings('ignore')

# 한글 폰트 설정
plt.rcParams['font.family'] = 'Gulim'

# 데이터는 함수 내에서 로드하는 것이 더 안전합니다.
# df = pd.read_excel("./data/TotalData3.xlsx")

def get_total_supply_by_region_2025():
    # 데이터 로드 (함수 호출 시마다 로드하는 것이 명확하지만, 성능 상 캐싱 고려 가능)
    df = pd.read_excel("./data/TotalData3.xlsx")

    # 'Date' 컬럼을 datetime 형식으로 변환 (필수)
    df['Date'] = pd.to_datetime(df['Date'])

    # '2025년' 데이터만 필터링
    # 주의: 현재 가지고 계신 TotalData3.xlsx 파일에 2025년 데이터가 없으면 빈 그래프가 생성됩니다.
    # 예측 모델을 통해 2025년 데이터를 생성한 후에 이 함수를 호출하는 것이 일반적입니다.
    # 여기서는 'TotalData3.xlsx'에 2025년 실제 데이터가 있다고 가정합니다.
    df_2025 = df[df['Date'].dt.year == 2025]

    # 지역별 공급량 합계 계산
    if df_2025.empty:
        # 2025년 데이터가 없는 경우를 처리
        print("경고: TotalData3.xlsx 파일에 2025년 데이터가 없습니다. 빈 그래프를 반환합니다.")
        # 빈 그래프를 반환하거나 오류 메시지를 포함할 수 있습니다.
        plt.figure(figsize=(10, 6))
        plt.text(0.5, 0.5, "2025년 데이터 없음", horizontalalignment='center', verticalalignment='center', transform=plt.gca().transAxes, fontsize=15, color='red')
        plt.title('2025년 지역별 가스 공급량 합계', fontsize=16)
        plt.xlabel('지역', fontsize=12)
        plt.ylabel('총 가스 공급량', fontsize=12)
        plt.xticks(rotation=45, ha='right')
        plt.tight_layout()
        buf = io.BytesIO()
        plt.savefig(buf, format='png')
        plt.close()
        buf.seek(0)
        return {"plot_image_base64": base64.b64encode(buf.read()).decode('utf-8'),
                "message": "2025년 데이터가 없어 그래프를 생성할 수 없습니다. 예측 모델 사용을 고려하세요."}

    region_supply = df_2025.groupby('Local')['GasSupply'].sum().reset_index()
    region_supply.columns = ['Local', 'total_supply']

    # 막대 그래프 시각화
    plt.figure(figsize=(12, 7))
    sns.barplot(x='Local', y='total_supply', data=region_supply, palette='viridis')
    plt.title('2025년 지역별 가스 공급량 합계', fontsize=16)
    plt.xlabel('지역', fontsize=12)
    plt.ylabel('총 가스 공급량', fontsize=12)
    plt.xticks(rotation=45, ha='right') # 지역 이름이 길 경우 회전
    plt.grid(axis='y', linestyle='--', alpha=0.7)

    # 그래프를 메모리에 저장하고 base64로 인코딩
    buf = io.BytesIO()
    plt.tight_layout() # 레이블 겹침 방지
    plt.savefig(buf, format='png')
    plt.close() # 메모리 해제
    buf.seek(0)
    plot_base64 = base64.b64encode(buf.read()).decode('utf-8')

    # 그래프 이미지와 함께 데이터도 반환 (선택 사항)
    return {
        "plot_image_base64": plot_base64,
        "data": region_supply.to_dict(orient="records")
    }

def get_local_result(selected_local=None):
    """
    각 지역의 월별 도시가스 공급량
    """
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
    
    return {"chartImage": local_chart,
            "selected_local": selected_local}


def load_and_preprocess_data():
    """
    데이터 로드 및 전처리 함수
    - 결측치 처리
    - 시계열 데이터 정렬
    """
    # 데이터 로드
    df = pd.read_excel("./data/TotalData3.xlsx")
    
    # 결측치 처리
    df.fillna(0, inplace=True)
    
    # 지역 문자열 인코딩 (전역적으로 사용하도록 여기에 추가)
    le = LabelEncoder()
    df['Local_encoded'] = le.fit_transform(df['Local'])

    # 날짜 컬럼 정렬
    df['Date'] = pd.to_datetime(df['Date'])  # 엑셀에서 날짜로 합친 경우
    df = df.sort_values('Date')
    
    return df