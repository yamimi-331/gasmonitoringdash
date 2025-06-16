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
    df = pd.read_excel("./data/TotalData3.xlsx")
    
    # 결측치 처리
    df.fillna(0, inplace=True)
    
    # 지역 코드를 숫자로 변환 (R01~R17)
    # region_mapping = {f'R{i:02d}': i for i in range(1, 18)}
    # df['Local'] = df['Local'].map(region_mapping)
    
    # 날짜 컬럼 정렬
    df['Date'] = pd.to_datetime(df['Date'])  # 엑셀에서 날짜로 합친 경우
    df = df.sort_values('Date')
    
    return df

# 가스 공급량및 수요예측 그래프
def plot_supply_prediction_timeline(df, results, start_date='2020-01-01', end_date=None):
    df = df.copy()
    df['YearMonth'] = df['Date'].dt.to_period('M').astype(str)

    # XGBoost 모델 가져오기
    model = results['XGBoost']['model']

    # 기간 설정
    if end_date is None:
        end_date = df['Date'].max()
    date_range = pd.date_range(start=start_date, end=end_date, freq='MS')
    year_month_list = date_range.to_period('M').astype(str)

    # 날짜 숫자 변환 & 지역 인코딩 (모델 입력 준비)
    date_ordinals = date_range.map(pd.Timestamp.toordinal).values

    # 모든 지역을 포함하는 입력 생성 (지역별로 동일한 날짜 반복)
    locals_ = df['Local'].unique()
    X_pred_list = []
    pred_dates = []
    for local in locals_:
        local_df = df[df['Local'] == local] # 지역별 데이터 미리 필터링
        local_encoded = local_df['Local_encoded'].iloc[0] # 지역 인코딩 값은 동일

        for date_obj in date_range: # pd.Timestamp 객체로 직접 사용
            date_ord = date_obj.toordinal()
            year_month_str = str(date_obj.to_period('M'))

            # 해당 월의 데이터가 있는지 확인
            current_month_data = local_df[local_df['Date'].dt.to_period('M') == year_month_str]

            temp_val = current_month_data['Temperature'].mean() if not current_month_data.empty else None
            hum_val = current_month_data['Humidity'].mean() if not current_month_data.empty else None
            pop_val = current_month_data['Population'].mean() if not current_month_data.empty else None

            # 미래 예측 시점에 대한 특징 값 추정 로직 추가
            if temp_val is None:
                # 예시: 전년 동월의 평균 온도/습도/인구 사용
                # 실제 데이터에 맞춰 더 정교한 로직 필요
                prev_year_date = date_obj - pd.DateOffset(years=1)
                prev_year_month_data = local_df[local_df['Date'].dt.to_period('M') == str(prev_year_date.to_period('M'))]

                if not prev_year_month_data.empty:
                    temp_val = prev_year_month_data['Temperature'].mean()
                    hum_val = prev_year_month_data['Humidity'].mean()
                    pop_val = prev_year_month_data['Population'].mean()
                else:
                    # 전년 동월 데이터도 없으면 전체 평균 사용 (최후의 수단)
                    temp_val = df['Temperature'].mean()
                    hum_val = df['Humidity'].mean()
                    pop_val = df['Population'].mean()

            X_pred_list.append([
                date_ord,
                local_encoded,
                temp_val,
                hum_val,
                pop_val
            ])
            pred_dates.append((local, year_month_str))
    X_pred = np.array(X_pred_list)

    # 예측 수행
    y_pred = model.predict(X_pred)

    # 지역별 월별 예측 합산
    pred_df = pd.DataFrame(pred_dates, columns=['Local', 'YearMonth'])
    pred_df['GasSupply'] = y_pred
    monthly_pred = pred_df.groupby('YearMonth')['GasSupply'].sum().reset_index()

    # 실제 월별 데이터
    monthly_actual = df.groupby('YearMonth')['GasSupply'].sum().reset_index()
    monthly_actual['Type'] = '실제'
    monthly_pred['Type'] = '예측'

    # 실제+예측 합치기
    plot_df = pd.concat([monthly_actual, monthly_pred])
    plot_df = plot_df.drop_duplicates(subset=['YearMonth', 'Type'])
    plot_df = plot_df.sort_values('YearMonth')

    # 막대 그래프 그리기
    plt.figure(figsize=(14, 6))
    sns.barplot(data=plot_df, x='YearMonth', y='GasSupply', hue='Type', palette={'실제': 'dodgerblue', '예측': 'skyblue'})
    plt.xticks(rotation=45)
    plt.title('가스 공급량 (실제 vs 예측)')
    plt.xlabel('연월')
    plt.ylabel('가스 공급량')
    plt.legend(title='데이터 유형')

    buf = io.BytesIO()
    plt.tight_layout()
    plt.savefig(buf, format='png')
    plt.close()
    buf.seek(0)

    return base64.b64encode(buf.read()).decode('utf-8')


def create_visualizations(df, results, X_test, y_test):
    """
    다양한 시각화 생성
    - 월별 평균 가스 공급량 추이
    - 온도와 가스 공급량의 관계
    - 지역별 가스 공급량 패턴
    - 모델별 예측 결과 비교
    """
    visualizations = {}
    
   
    
    return visualizations


def prepare_time_series_data(df):
    """
    시계열 데이터 준비
    - Prophet 모델용 데이터프레임 생성
    - LSTM 모델용 시퀀스 데이터 생성
    """
    # Prophet용 데이터 준비
    prophet_df = df.groupby('Date')['GasSupply'].sum().reset_index()
    prophet_df.columns = ['ds', 'y']
    
    # LSTM용 데이터 준비
    sequence_length = 12  # 12개월 시퀀스
    X_lstm = []
    y_lstm = []
    
    for region in df['Local'].unique():
        region_data = df[df['Local'] == region]
        for i in range(len(region_data) - sequence_length):
            X_lstm.append(region_data[['Temperature', 'Humidity', 'Population']].iloc[i:i+sequence_length].values)
            y_lstm.append(region_data['GasSupply'].iloc[i+sequence_length])
    
    return prophet_df, np.array(X_lstm), np.array(y_lstm)

def train_models(df):
    """
    다양한 모델 학습
    - XGBoost: 지역별 특성과 기온, 습도 등을 고려한 예측
    - Prophet: 시계열 특성을 고려한 예측
    - LSTM: 시계열 패턴 학습
    """
     # 날짜 숫자화
    df['date_ordinal'] = df['Date'].map(pd.Timestamp.toordinal)

    # 지역 문자열 인코딩
    le = LabelEncoder()
    df['Local_encoded'] = le.fit_transform(df['Local'])

    # X, y 정의
    X = df[['date_ordinal', 'Local_encoded', 'Temperature', 'Humidity', 'Population']]
    y = df['GasSupply']
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
    
    # 새 함수 호출 (예측 포함 타임라인)
    timeline_img = plot_supply_prediction_timeline(df, results, start_date='2020-01-01', end_date='2025-07-31')
    visualizations['supply_prediction_timeline'] = timeline_img

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