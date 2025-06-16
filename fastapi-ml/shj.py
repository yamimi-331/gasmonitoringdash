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
import pickle
from keras.models import load_model
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import LSTM, Dense, Dropout
from sklearn.preprocessing import LabelEncoder, MinMaxScaler # MinMaxScaler 추가
import io
import base64
import joblib
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
    
    # 지역 문자열 인코딩 (전역적으로 사용하도록 여기에 추가)
    le = LabelEncoder()
    df['Local_encoded'] = le.fit_transform(df['Local'])

    # 날짜 컬럼 정렬
    df['Date'] = pd.to_datetime(df['Date'])  # 엑셀에서 날짜로 합친 경우
    df = df.sort_values('Date')
    
    return df

def prepare_time_series_data(df, sequence_length=12):
    """
    시계열 데이터 준비
    - Prophet 모델용 데이터프레임 생성
    - LSTM 모델용 시퀀스 데이터 생성(MinMaxScaler 적용)
    """
    # Prophet용 데이터 준비
    prophet_df = df.groupby('Date')['GasSupply'].sum().reset_index()
    prophet_df.columns = ['ds', 'y']
    
    # LSTM용 데이터 준비
     # LSTM용 데이터 준비
    # LSTM 입력 피처 (Temperature, Humidity, Population) 스케일링
    features_to_scale = ['Temperature', 'Humidity', 'Population']
    scaler_X = MinMaxScaler()
    df[features_to_scale] = scaler_X.fit_transform(df[features_to_scale])

    # GasSupply (예측 타겟) 스케일링 (LSTM 예측값 역변환을 위해)
    scaler_y = MinMaxScaler()
    # 주의: GasSupply는 예측 대상이므로, fit_transform을 전체 데이터에 적용하여 스케일링 범위 학습
    # 예측 시에는 InverseTransform을 위해 scaler_y 객체를 반환해야 함
    df['GasSupply_scaled'] = scaler_y.fit_transform(df[['GasSupply']])

    X_lstm = []
    y_lstm = []
    local_lstm = [] # 어떤 지역의 시퀀스인지 추적

    for region_code in df['Local_encoded'].unique(): # 인코딩된 지역 코드로 반복
        region_data = df[df['Local_encoded'] == region_code].sort_values('Date')
        # 필요한 컬럼만 추출하여 시퀀스 생성
        region_features = region_data[features_to_scale + ['GasSupply_scaled']].values # GasSupply_scaled도 시퀀스에 포함할 수 있음 (선택 사항)

        for i in range(len(region_data) - sequence_length):
            # 입력 시퀀스는 Temperature, Humidity, Population만 사용
            X_lstm.append(region_data[features_to_scale].iloc[i:i+sequence_length].values)
            # 타겟은 GasSupply_scaled
            y_lstm.append(region_data['GasSupply_scaled'].iloc[i+sequence_length])
            local_lstm.append(region_code)


    return prophet_df, np.array(X_lstm), np.array(y_lstm), scaler_X, scaler_y, np.array(local_lstm)


def train_models(df):
    """
    다양한 모델 학습
    - XGBoost: 지역별 특성과 기온, 습도 등을 고려한 예측
    - Prophet: 시계열 특성을 고려한 예측
    - LSTM: 시계열 패턴 학습
    """
     # 날짜 숫자화
    df['date_ordinal'] = df['Date'].map(pd.Timestamp.toordinal)

   # X, y 정의 (XGBoost용)
    # GasSupply_scaled는 LSTM용이므로 XGBoost에서는 원래 GasSupply 사용
    X_xgb = df[['date_ordinal', 'Local_encoded', 'Temperature', 'Humidity', 'Population']]
    y_xgb = df['GasSupply'] # 원본 GasSupply 사용
    X_train_xgb, X_test_xgb, y_train_xgb, y_test_xgb = train_test_split(X_xgb, y_xgb, test_size=0.2, random_state=42)

    xgb_model = xgb.XGBRegressor(
        n_estimators=100,
        learning_rate=0.1,
        max_depth=5,
        random_state=42
    )
    xgb_model.fit(X_train_xgb, y_train_xgb)
    xgb_pred = xgb_model.predict(X_test_xgb)

    # 모델 평가 (XGBoost)
    xgb_mse = mean_squared_error(y_test_xgb, xgb_pred)
    xgb_rmse = np.sqrt(xgb_mse)
    xgb_r2 = r2_score(y_test_xgb, xgb_pred)

    # Prophet 모델 학습
    prophet_df, X_lstm, y_lstm, scaler_X, scaler_y, local_lstm_array = prepare_time_series_data(df.copy()) # df.copy()로 원본 df 보호
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

    # 모델 평가 (Prophet, LSTM은 별도 예측 함수에서 시각화하며 평가)
    results = {
        'XGBoost': {
            'model': xgb_model,
            'mse': xgb_mse,
            'rmse': xgb_rmse,
            'r2': xgb_r2,
            'X_test': X_test_xgb, # XGBoost test set도 함께 반환
            'y_test': y_test_xgb
        },
        'Prophet': {
            'model': prophet_model,
            'prophet_df': prophet_df # Prophet 예측에 사용될 데이터도 함께 반환
        },
        'LSTM': {
            'model': lstm_model,
            'scaler_X': scaler_X,
            'scaler_y': scaler_y,
            # LSTM 예측을 위한 원본 데이터프레임과 시퀀스 길이 정보 추가
            'original_df': df.copy(), # LSTM 예측을 위해 전처리 전/후 원본 df 필요
            'sequence_length': 12
        }
    }
    
    return results

# 가스 공급량및 수요예측 그래프(XGBoost 기반)
def plot_supply_prediction_timeline(df, results, start_date='2020-01-01', end_date=None):
    df = df.copy()
    df['YearMonth'] = df['Date'].dt.to_period('M').astype(str)

    # XGBoost 모델 가져오기
    xgb_model = results['XGBoost']['model']

    # 기간 설정
    if end_date is None:
        end_date = df['Date'].max()
    date_range = pd.date_range(start=start_date, end=end_date, freq='MS')

     # 모든 지역을 포함하는 입력 생성 (지역별로 동일한 날짜 반복)
    locals_encoded = df['Local_encoded'].unique() # 인코딩된 지역 코드 사용
    le_inverse_map = {v: k for k, v in dict(zip(df['Local'], df['Local_encoded'])).items()} # 역매핑 딕셔너리 생성

    X_pred_list = []
    pred_dates_info = [] # (Local_encoded, YearMonth_str, Date_obj) 저장

    # 예측 기간 동안의 Temperature, Humidity, Population 값 추정
    # 가장 최근 12개월의 월별 평균을 사용하여 반복 (간단한 계절성 고려)
    recent_data = df[df['Date'] >= (df['Date'].max() - pd.DateOffset(months=11))]
    avg_features_by_month = recent_data.groupby(recent_data['Date'].dt.month)[['Temperature', 'Humidity', 'Population']].mean()


    for date_obj in date_range:
        date_ord = date_obj.toordinal()
        month = date_obj.month

        # 해당 월의 평균 특징 값 사용 (없으면 전체 평균)
        temp_val = avg_features_by_month.loc[month, 'Temperature'] if month in avg_features_by_month.index else df['Temperature'].mean()
        hum_val = avg_features_by_month.loc[month, 'Humidity'] if month in avg_features_by_month.index else df['Humidity'].mean()
        pop_val = avg_features_by_month.loc[month, 'Population'] if month in avg_features_by_month.index else df['Population'].mean()

        for local_encoded in locals_encoded:
            X_pred_list.append([
                date_ord,
                local_encoded,
                temp_val,
                hum_val,
                pop_val
            ])
            pred_dates_info.append((local_encoded, str(date_obj.to_period('M')), date_obj)) # 인코딩된 지역 코드와 날짜 정보 저장

    X_pred_xgb = np.array(X_pred_list)

    # 예측 수행
    y_pred_xgb = xgb_model.predict(X_pred_xgb)

    # 지역별 월별 예측 합산
    pred_df_xgb = pd.DataFrame(pred_dates_info, columns=['Local_encoded', 'YearMonth', 'Date'])
    pred_df_xgb['GasSupply'] = y_pred_xgb
    monthly_pred_xgb = pred_df_xgb.groupby('YearMonth')['GasSupply'].sum().reset_index()

    # 실제 월별 데이터
    monthly_actual = df.groupby('YearMonth')['GasSupply'].sum().reset_index()
    monthly_actual['Type'] = '실제'

    # 예측 데이터 (원본 데이터의 가장 최신 날짜 이후부터 예측)
    last_actual_month = df['YearMonth'].max()
    monthly_pred_xgb = monthly_pred_xgb[monthly_pred_xgb['YearMonth'] > last_actual_month]
    monthly_pred_xgb['Type'] = '예측'

    # 실제+예측 합치기
    plot_df = pd.concat([monthly_actual, monthly_pred_xgb])
    plot_df = plot_df.sort_values('YearMonth').reset_index(drop=True)

    # 막대 그래프 그리기
    plt.figure(figsize=(16, 7))
    sns.barplot(data=plot_df, x='YearMonth', y='GasSupply', hue='Type', palette={'실제': 'dodgerblue', '예측': 'skyblue'})
    plt.xticks(rotation=60, ha='right', fontsize=8) # x축 레이블 회전 및 글씨 크기 조정
    plt.title('가스 공급량 (실제 vs 예측) - XGBoost 모델', fontsize=15)
    plt.xlabel('연월', fontsize=12)
    plt.ylabel('가스 공급량', fontsize=12)
    plt.legend(title='데이터 유형', fontsize=10, title_fontsize=12)
    plt.grid(axis='y', linestyle='--', alpha=0.7)

    # x축 레이블 간격 조정 (너무 많을 경우)
    n_ticks = len(plot_df['YearMonth'].unique())
    if n_ticks > 20: # 예를 들어, 20개 이상이면 간격 조정
        tick_interval = n_ticks // 10
        plt.gca().set_xticks(plt.gca().get_xticks()[::tick_interval])
        plt.gca().set_xticklabels(plot_df['YearMonth'].unique()[::tick_interval])


    buf = io.BytesIO()
    plt.tight_layout()
    plt.savefig(buf, format='png')
    plt.close()
    buf.seek(0)

    return base64.b64encode(buf.read()).decode('utf-8')

# Prophet 모델 예측 및 시각화 함수 추가
def plot_prophet_prediction(prophet_model, prophet_df, forecast_periods=24):
    """
    Prophet 모델의 미래 예측을 수행하고 시각화합니다.
    """
    future = prophet_model.make_future_dataframe(periods=forecast_periods, freq='MS') # 24개월 (2년) 예측
    forecast = prophet_model.predict(future)

    # 실제 데이터와 예측 데이터를 하나의 DataFrame으로 합치기 (시각화용)
    plot_df = prophet_df.copy()
    plot_df['type'] = '실제'

    forecast_plot_df = forecast[['ds', 'yhat']].rename(columns={'yhat': 'y'})
    # 예측 데이터는 실제 데이터의 마지막 날짜 이후부터 시작
    last_actual_date = prophet_df['ds'].max()
    forecast_plot_df = forecast_plot_df[forecast_plot_df['ds'] > last_actual_date]
    forecast_plot_df['type'] = '예측'

    combined_df = pd.concat([plot_df, forecast_plot_df])

    plt.figure(figsize=(16, 7))
    sns.lineplot(data=combined_df, x='ds', y='y', hue='type', palette={'실제': 'dodgerblue', '예측': 'skyblue'})
    plt.fill_between(forecast['ds'], forecast['yhat_lower'], forecast['yhat_upper'], color='gray', alpha=0.2, label='신뢰 구간')
    plt.title('Prophet 모델: 가스 공급량 예측', fontsize=15)
    plt.xlabel('날짜', fontsize=12)
    plt.ylabel('가스 공급량', fontsize=12)
    plt.legend(title='데이터 유형', fontsize=10, title_fontsize=12)
    plt.grid(axis='y', linestyle='--', alpha=0.7)
    plt.xticks(rotation=45, ha='right')

    buf = io.BytesIO()
    plt.tight_layout()
    plt.savefig(buf, format='png')
    plt.close()
    buf.seek(0)

    return base64.b64encode(buf.read()).decode('utf-8')

# LSTM 모델 예측 및 시각화 함수 추가
def predict_lstm_future(lstm_model, original_df, scaler_X, scaler_y, sequence_length, forecast_periods=12, target_region_encoded=None):
    """
    LSTM 모델을 사용하여 미래를 예측합니다.
    (가장 최신 데이터를 기반으로 스텝별 예측)
    target_region_encoded: 특정 지역만 예측하고 싶을 경우 해당 지역의 인코딩된 값. None이면 모든 지역의 평균을 예측.
    """
    all_future_predictions = pd.DataFrame()
    features_to_scale = ['Temperature', 'Humidity', 'Population']

    # 원본 DF에서 인코딩된 지역 컬럼이 없으면 새로 생성
    if 'Local_encoded' not in original_df.columns:
        le = LabelEncoder()
        original_df['Local_encoded'] = le.fit_transform(original_df['Local'])

    # 예측할 지역 리스트 (단일 지역 또는 모든 지역)
    if target_region_encoded is not None:
        regions_to_predict = [target_region_encoded]
    else:
        regions_to_predict = original_df['Local_encoded'].unique()

    for region_code in regions_to_predict:
        region_df = original_df[original_df['Local_encoded'] == region_code].sort_values('Date').copy()

        # LSTM 예측을 위한 최신 시퀀스 준비
        # GasSupply_scaled는 예측 타겟이므로 시퀀스 입력에 포함하지 않음.
        # LSTM input_shape은 (samples, timesteps, features)
        # 따라서 Temperature, Humidity, Population만 스케일링된 상태로 가져옴
        last_sequence_data = region_df[features_to_scale].tail(sequence_length).values

        if len(last_sequence_data) < sequence_length:
            # 시퀀스 길이가 부족하면 예측 불가
            continue

        # 스케일링된 상태로 예측 시작 (prepare_time_series_data에서 scaler_X와 scaler_y가 생성되었어야 함)
        current_sequence = last_sequence_data.reshape(1, sequence_length, len(features_to_scale))

        # 미래 날짜 생성
        last_date = region_df['Date'].max()
        future_dates = pd.date_range(start=last_date + pd.DateOffset(months=1), periods=forecast_periods, freq='MS')

        region_predictions = []
        for i in range(forecast_periods):
            # 현재 시퀀스로 예측 수행
            predicted_scaled_supply = lstm_model.predict(current_sequence, verbose=0)[0][0]
            predicted_supply = scaler_y.inverse_transform([[predicted_scaled_supply]])[0][0]

            region_predictions.append({
                'Date': future_dates[i],
                'Local_encoded': region_code,
                'GasSupply': predicted_supply
            })

            # 다음 시퀀스를 위해 예측된 공급량과 특징을 추가 (Roll-forward)
            # 여기서는 다음 시점의 온도, 습도, 인구는 이전 월과 동일하다고 가정하거나, 평균값을 사용.
            # 실제 사용 시에는 이 부분에 미래 특징 값에 대한 더 정교한 추정 로직이 필요.
            # 간단하게 마지막 월의 특징 값을 반복 사용 (가장 간단한 방법)
            # 더 나은 방법: XGBoost 예측에서 사용한 월별 평균 특징 값 사용
            month = future_dates[i].month
            # original_df의 스케일링된 특징 평균 사용 (prepare_time_series_data에서 df가 스케일링되었음)
            avg_temp_scaled = original_df[original_df['Date'].dt.month == month]['Temperature'].mean()
            avg_hum_scaled = original_df[original_df['Date'].dt.month == month]['Humidity'].mean()
            avg_pop_scaled = original_df[original_df['Date'].dt.month == month]['Population'].mean()

            # 새로운 특징 벡터
            next_features = np.array([avg_temp_scaled, avg_hum_scaled, avg_pop_scaled])

            # 시퀀스 업데이트: 가장 오래된 데이터 제거, 새로운 예측 및 특징 추가
            current_sequence = np.append(current_sequence[:, 1:, :], next_features.reshape(1, 1, -1), axis=1)


        all_future_predictions = pd.concat([all_future_predictions, pd.DataFrame(region_predictions)], ignore_index=True)

    # 예측 결과를 월별 총합으로 집계
    monthly_lstm_pred = all_future_predictions.groupby('Date')['GasSupply'].sum().reset_index()
    monthly_lstm_pred['type'] = '예측'

    return monthly_lstm_pred


def plot_lstm_prediction(original_df, monthly_lstm_pred, forecast_periods=12):
    """
    LSTM 모델의 미래 예측을 시각화합니다.
    """
    # 실제 데이터
    monthly_actual_lstm = original_df.groupby(original_df['Date'].dt.to_period('M'))['GasSupply'].sum().reset_index()
    monthly_actual_lstm['Date'] = monthly_actual_lstm['Date'].dt.to_timestamp() # Period를 Timestamp로 변환
    monthly_actual_lstm['type'] = '실제'

    # 예측 데이터의 시작점을 실제 데이터의 마지막 날짜 이후로 설정
    last_actual_date = monthly_actual_lstm['Date'].max()
    monthly_lstm_pred_filtered = monthly_lstm_pred[monthly_lstm_pred['Date'] > last_actual_date]

    combined_df = pd.concat([monthly_actual_lstm, monthly_lstm_pred_filtered])
    combined_df = combined_df.sort_values('Date').reset_index(drop=True)

    plt.figure(figsize=(16, 7))
    sns.lineplot(data=combined_df, x='Date', y='GasSupply', hue='type', palette={'실제': 'dodgerblue', '예측': 'skyblue'})
    plt.title('LSTM 모델: 가스 공급량 예측', fontsize=15)
    plt.xlabel('날짜', fontsize=12)
    plt.ylabel('가스 공급량', fontsize=12)
    plt.legend(title='데이터 유형', fontsize=10, title_fontsize=12)
    plt.grid(axis='y', linestyle='--', alpha=0.7)
    plt.xticks(rotation=45, ha='right')

    buf = io.BytesIO()
    plt.tight_layout()
    plt.savefig(buf, format='png')
    plt.close()
    buf.seek(0)

    return base64.b64encode(buf.read()).decode('utf-8')


def create_visualizations(df, results): # X_test, y_test는 results 안에 포함되므로 제거
    """
    다양한 시각화 생성
    - 월별 평균 가스 공급량 추이
    - 온도와 가스 공급량의 관계
    - 지역별 가스 공급량 패턴
    - 모델별 예측 결과 비교
    """
    visualizations = {}

    # XGBoost의 X_test, y_test 가져오기
    X_test = results['XGBoost']['X_test']
    y_test = results['XGBoost']['y_test']

   # 1. 월별 평균 가스 공급량 추이 (막대 그래프로 변경)
    plt.figure(figsize=(12, 6))
    df['Month'] = df['Date'].dt.month  # date에서 월 정보 추출
    monthly_avg = df.groupby('Month')['GasSupply'].mean().reset_index() # reset_index()를 통해 DataFrame 형태로 변환
    sns.barplot(x='Month', y='GasSupply', data=monthly_avg, palette='viridis') # barplot 사용
    plt.title('월별 평균 가스 공급량 추이', fontsize=15)
    plt.xlabel('월', fontsize=12)
    plt.ylabel('평균 가스 공급량', fontsize=12)
    plt.xticks(rotation=0) # 월은 겹치지 않으므로 회전 불필요
    buf = io.BytesIO()
    plt.savefig(buf, format='png')
    plt.close()
    buf.seek(0)
    visualizations['monthly_trend'] = base64.b64encode(buf.read()).decode('utf-8')


    # 2. 온도와 가스 공급량의 관계
    plt.figure(figsize=(12, 6))
    sns.scatterplot(data=df, x='Temperature', y='GasSupply', hue='Local', palette='viridis', alpha=0.7)
    plt.title('온도와 가스 공급량의 관계 (지역별)', fontsize=15)
    plt.xlabel('온도', fontsize=12)
    plt.ylabel('가스 공급량', fontsize=12)
    plt.legend(title='지역')
    buf = io.BytesIO()
    plt.savefig(buf, format='png')
    plt.close()
    buf.seek(0)
    visualizations['temp_supply'] = base64.b64encode(buf.read()).decode('utf-8')

    # 3. 지역별 가스 공급량 분포
    plt.figure(figsize=(12, 6))
    sns.boxplot(data=df, x='Local', y='GasSupply', palette='Set3')
    plt.title('지역별 가스 공급량 분포', fontsize=15)
    plt.xlabel('지역 코드', fontsize=12)
    plt.ylabel('가스 공급량', fontsize=12)
    plt.xticks(rotation=45, ha='right')
    buf = io.BytesIO()
    plt.savefig(buf, format='png')
    plt.close()
    buf.seek(0)
    visualizations['regional_pattern'] = base64.b64encode(buf.read()).decode('utf-8')

    # 4. XGBoost 모델 예측 결과 (실제값 vs 예측값 산점도)
    # plt.figure(figsize=(12, 6))
    # y_pred_xgb = results['XGBoost']['model'].predict(X_test)
    # plt.scatter(y_test, y_pred_xgb, alpha=0.6, color='purple')
    # plt.plot([y_test.min(), y_test.max()], [y_test.min(), y_test.max()], 'r--', lw=2)
    # plt.title('XGBoost 모델: 실제값 vs 예측값', fontsize=15)
    # plt.xlabel('실제 가스 공급량', fontsize=12)
    # plt.ylabel('예측 가스 공급량', fontsize=12)
    # buf = io.BytesIO()
    # plt.savefig(buf, format='png')
    # plt.close()
    # buf.seek(0)
    # visualizations['xgboost_prediction_comparison'] = base64.b64encode(buf.read()).decode('utf-8')

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
    results = train_models(df.copy()) # 원본 df가 prepare_time_series_data에서 스케일링되므로 복사본 전달

    # 시각화 생성
    visualizations = create_visualizations(df.copy(), results) # 원본 df의 복사본 전달

    # 새 함수 호출 (예측 포함 타임라인 - XGBoost)
    # 2025년 7월 31일까지 예측하도록 end_date 설정 (현재 날짜 이후 12개월 이상 예측)
    timeline_xgb_img = plot_supply_prediction_timeline(df.copy(), results, start_date='2020-01-01', end_date='2025-07-31')
    visualizations['supply_prediction_timeline_xgboost'] = timeline_xgb_img

    # Prophet 모델 예측 및 시각화
    prophet_model = results['Prophet']['model']
    prophet_df_for_plot = results['Prophet']['prophet_df'] # Prophet 학습에 사용된 df
    prophet_prediction_img = plot_prophet_prediction(prophet_model, prophet_df_for_plot, forecast_periods=24) # 2년 예측
    visualizations['prophet_prediction_timeline'] = prophet_prediction_img

    # LSTM 모델 예측 및 시각화
    lstm_model = results['LSTM']['model']
    original_df_for_lstm = results['LSTM']['original_df'] # 스케일링 전 원본 데이터프레임
    scaler_X_lstm = results['LSTM']['scaler_X']
    scaler_y_lstm = results['LSTM']['scaler_y']
    sequence_length_lstm = results['LSTM']['sequence_length']

    # LSTM 미래 예측 수행 (예: 다음 12개월 예측)
    # 특정 지역을 지정하지 않으면 모든 지역의 합산 예측을 반환
    monthly_lstm_forecast = predict_lstm_future(
        lstm_model,
        original_df_for_lstm,
        scaler_X_lstm,
        scaler_y_lstm,
        sequence_length_lstm,
        forecast_periods=12 # 12개월 예측
    )
    lstm_prediction_img = plot_lstm_prediction(original_df_for_lstm, monthly_lstm_forecast, forecast_periods=12)
    visualizations['lstm_prediction_timeline'] = lstm_prediction_img


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

def plot_supply_prediction_timeline_A(df, model_type='xgboost', start_date=None, end_date=None):
    """
    저장된 모델을 불러와서 특정 구간의 가스 공급량을 예측하고 시각화합니다.
    """
    df = df.copy()
    df['Date'] = pd.to_datetime(df['Date'])
    df['date_ordinal'] = df['Date'].map(pd.Timestamp.toordinal)

    if 'Local' in df.columns:
        df['Local_encoded'] = df['Local'].astype('category').cat.codes
    else:
        df['Local_encoded'] = 0

    # 날짜 필터
    if start_date:
        df = df[df['Date'] >= pd.to_datetime(start_date)]
    if end_date:
        df = df[df['Date'] <= pd.to_datetime(end_date)]

    # 예측 수행
    if model_type == 'xgboost':
        model = joblib.load('models/xgb_model.pkl')
        X = df[['date_ordinal', 'Local_encoded', 'Temperature', 'Humidity', 'Population']]
        df['Predicted'] = model.predict(X)

    elif model_type == 'prophet':
        with open('models/prophet_model.pkl', 'rb') as f:
            model = pickle.load(f)
        future = df[['Date']].rename(columns={"Date": "ds"})
        forecast = model.predict(future)
        df = df.merge(forecast[['ds', 'yhat']], left_on='Date', right_on='ds', how='left')
        df['Predicted'] = df['yhat']

    elif model_type == 'lstm':
        model = load_model('models/lstm_model.h5')
        scaler_X = joblib.load('models/lstm_scaler_X.pkl')
        scaler_y = joblib.load('models/lstm_scaler_y.pkl')

        features = ['date_ordinal', 'Local_encoded', 'Temperature', 'Humidity', 'Population']
        seq_len = 12
        X_scaled = scaler_X.transform(df[features])

        X_seq = []
        for i in range(seq_len, len(X_scaled)):
            X_seq.append(X_scaled[i - seq_len:i])
        X_seq = np.array(X_seq)

        y_pred = model.predict(X_seq)
        y_pred_inv = scaler_y.inverse_transform(y_pred)
        df = df.iloc[seq_len:].copy()  # 시퀀스 자른 만큼 자르기
        df['Predicted'] = y_pred_inv.flatten()

    else:
        raise ValueError("지원하지 않는 모델입니다: 'xgboost', 'prophet', 'lstm' 중 선택하세요.")

    # 예측 결과 그리기 (이미지 생성용)
    fig, ax = plt.subplots(figsize=(12, 6))
    ax.plot(df['Date'], df['GasSupply'], label='실제 공급량', marker='o')
    ax.plot(df['Date'], df['Predicted'], label='예측값', linestyle='--')
    ax.set_title(f'{model_type.upper()} 모델 - 가스 공급량 예측')
    ax.set_xlabel('날짜')
    ax.set_ylabel('공급량')
    ax.legend()
    ax.grid(True)
    plt.tight_layout()

    # 이미지 버퍼에 저장
    buf = io.BytesIO()
    plt.savefig(buf, format='png')
    buf.seek(0)
    img_base64 = base64.b64encode(buf.read()).decode('utf-8')
    buf.close()
    plt.close(fig)  # 메모리 누수 방지

    return {"image_base64": f"data:image/png;base64,{img_base64}"}
