#  LSTM 전처리 – 핵심 목표
# 시계열 데이터 정렬 및 시퀀스 생성

# 입력값(X), 타깃값(y) 생성

# 스케일링 (MinMaxScaler 등으로 정규화)

# (선택) 지역 등 범주형 변수 인코딩
import pandas as pd
import numpy as np
from sklearn.preprocessing import MinMaxScaler, LabelEncoder

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