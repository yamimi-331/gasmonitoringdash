#  LSTM 전처리 – 핵심 목표
# 시계열 데이터 정렬 및 시퀀스 생성

# 입력값(X), 타깃값(y) 생성

# 스케일링 (MinMaxScaler 등으로 정규화)

# (선택) 지역 등 범주형 변수 인코딩
import pandas as pd
import numpy as np
from sklearn.preprocessing import MinMaxScaler, LabelEncoder


# 시퀀스 데이터 생성 함수
def create_sequences(X, y, sequence_length=12):
    """
    주어진 X, y 데이터를 시퀀스 형태로 변환하는 함수
    예: 12개월치 데이터를 입력으로 다음 달 공급량 예측
    """
    X_seq, y_seq = [], []
    for i in range(len(X) - sequence_length):
        X_seq.append(X[i:i + sequence_length])
        y_seq.append(y[i + sequence_length])
    return np.array(X_seq), np.array(y_seq)

# LSTM 모델을 위한 전처리 함수
def preprocess_lstm(df, sequence_length=12):
    """
    리턴값
    X_seq: (샘플 수, 시퀀스 길이, 입력 차원) 형태의 LSTM 입력 시퀀스 데이터
    y_seq: 각 시퀀스에 대한 타겟값 (다음달 공급량, 정규화됨)
    scaler_X: 학습 데이터에 맞춰 학습된 입력 데이터 정규화 도구 (예측 시 사용)
    scaler_y: 학습 데이터에 맞춰 학습된 출력값 정규화 도구 (예측 결과 역변환 시 사용)
    """
    # 1. 날짜 정렬 (시계열 순서 중요)
    df = df.sort_values('Date').reset_index(drop=True)

    # 2. 범주형 변수 'Local' 인코딩 (Label Encoding)
    if 'Local' in df.columns:
        le = LabelEncoder()
        df['Local_encoded'] = le.fit_transform(df['Local'])
    else:
        df['Local_encoded'] = 0  # 컬럼이 없으면 기본값

    # 3. 입력 특성과 예측 대상 선택
    feature_cols = ['GasSupply', 'Temperature', 'Humidity', 'Population', 'Local_encoded']
    X = df[feature_cols].values
    y = df['GasSupply'].values  # 예측 대상은 공급량

    # 4. 정규화 (0~1 사이로 변환)
    scaler_X = MinMaxScaler()
    scaler_y = MinMaxScaler()

    X_scaled = scaler_X.fit_transform(X)
    y_scaled = scaler_y.fit_transform(y.reshape(-1, 1))

    # 5. 시퀀스 생성
    X_seq, y_seq = create_sequences(X_scaled, y_scaled, sequence_length)

    return X_seq, y_seq, scaler_X, scaler_y, le

def preprocess_lstm_by_region(df, sequence_length=12):
    """
    각 지역(Local)별로 개별 시계열 데이터로 전처리 수행
    Returns:
        region_data: {
            지역명: {
                'X_seq': np.array,
                'y_seq': np.array,
                'scaler_X': MinMaxScaler,
                'scaler_y': MinMaxScaler
            },
            ...
        }
    """
    region_data = {} # 리턴값
    grouped = df.groupby('Local') #지역별로 그룹화

    for region, region_df in grouped:
        try:
            # 원래 전처리 함수 재사용
            X_seq, y_seq, scaler_X, scaler_y, le = preprocess_lstm(region_df, sequence_length)
            region_data[region] = {
                'X_seq': X_seq,
                'y_seq': y_seq,
                'scaler_X': scaler_X,
                'scaler_y': scaler_y,
                'le': le 
            }
            print(f"전처리 완료: {region} (시퀀스 {len(X_seq)}개)")
        except Exception as e:
            print(f"[오류] {region} 지역 전처리 실패: {e}")

    return region_data


# 지우지마
# 새로운 예측 전용 전처리 함수 
def prepare_data_for_single_prediction(df, scaler_X, le,sequence_length=12):
    """
    단일 시점 예측을 위해 12개월 데이터를 LSTM 입력 형태로 변환하는 함수.
    이 함수는 이미 학습된 scaler_X를 사용해야 합니다.
    """
    df = df.sort_values('Date').reset_index(drop=True)

    if 'Local' in df.columns:
        try:
            df['Local_encoded'] = le.transform(df['Local'])
        except Exception as e:
            print(f"[경고] LabelEncoder 변환 오류: {e}. 'Local' 값이 학습 데이터에 없거나 le가 잘못됨.")
            # 오류 발생 시, 0으로 처리하거나 다른 기본값을 할당하는 로직 필요
            df['Local_encoded'] = 0 # 임시 처리
    else:
        df['Local_encoded'] = 0

    feature_cols = ['GasSupply', 'Temperature', 'Humidity', 'Population', 'Local_encoded']
    X_raw = df[feature_cols].values

    if len(X_raw) != sequence_length:
        print(f"  [❌ 오류] 예측을 위한 데이터 길이 불일치: {len(X_raw)}개 (예상 {sequence_length}개)")
        return None

    # 이미 학습된 scaler_X로 변환
    X_scaled = scaler_X.transform(X_raw)

    # LSTM 모델 입력 형태 (1, sequence_length, features)로 reshape
    # 1은 샘플 수 (하나의 시퀀스), sequence_length는 시간 스텝, X_scaled.shape[1]은 피처 수
    X_prepared = X_scaled.reshape(1, sequence_length, X_scaled.shape[1])

    return X_prepared