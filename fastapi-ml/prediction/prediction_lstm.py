# ✅ 필요한 라이브러리
import numpy as np
import pandas as pd
import joblib
from tensorflow.keras.models import load_model
import tensorflow.keras.losses
import sys
import os

# 루트 경로 추가
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from preprocessing.preprocessing_lstm import preprocess_lstm  # 전처리 함수 불러오기

def predict_lstm(df, sequence_length=12, predict_months=3):
    """
    학습된 LSTM 모델을 이용해 향후 n개월 공급량 예측
    Args:
        df: 원본 데이터프레임
        sequence_length: 시퀀스 길이 (기본값 12개월)
        predict_months: 예측할 미래 개월 수 (기본값 3개월)
    Returns:
        predictions: 예측된 공급량 리스트 (정규화 복원됨)
    """

    # 모델 및 스케일러 불러오기
    model = load_model('models/models_lstm.h5', custom_objects={'mse': tensorflow.keras.losses.MeanSquaredError()})
    scaler_X = joblib.load('models/lstm_scaler_X.pkl')
    scaler_y = joblib.load('models/lstm_scaler_y.pkl')

    # 전체 데이터 전처리 (시퀀스 포함)
    # X_seq 값만 리턴받을경우 나머지 무시하기위해 _ 사용 
    X_seq, _, _, _ = preprocess_lstm(df, sequence_length)

    # 마지막 시퀀스 가져오기
    last_sequence = X_seq[-1]  # shape: (sequence_length, features)

    predictions = []

    for _ in range(predict_months):
        # 모델 예측
        input_seq = np.expand_dims(last_sequence, axis=0)  # shape: (1, seq_len, features)
        pred_scaled = model.predict(input_seq, verbose=0)
        pred = scaler_y.inverse_transform(pred_scaled)[0][0]  # 정규화 복원
        predictions.append(pred)

        # 시퀀스 갱신
        new_input = last_sequence[-1].copy()
        new_input[0] = pred_scaled[0][0]  # 첫 번째 피처가 공급량이라고 가정

        # 이전 시퀀스에서 첫 번째 제거하고 새로운 값 추가
        last_sequence = np.vstack([last_sequence[1:], new_input])

    return predictions

def predict_lstm_by_region(df, region_name, sequence_length=12, predict_months=3):
    """
    특정 지역의 학습된 LSTM 모델을 이용해 향후 n개월 공급량 예측

    Args:
        df: 원본 데이터프레임 (Local 포함)
        region_name: 예측할 지역 이름 (예: '강원특별자치도')
        sequence_length: 시퀀스 길이 (기본 12개월)
        predict_months: 예측 개월 수 (기본 3개월)

    Returns:
        predictions: 해당 지역의 예측 공급량 리스트 [1개월 후, 2개월 후, ...]
    """

    from preprocessing.preprocessing_lstm import preprocess_lstm

    # 해당 지역 데이터만 필터링
    region_df = df[df['Local'] == region_name].copy()

    if region_df.empty:
        print(f"[오류] {region_name} 지역 데이터 없음")
        return None

    # 모델 및 스케일러 경로
    model_path = f'models/region/{region_name}_lstm.h5'
    scaler_X_path = f'models/region/{region_name}_scaler_X.pkl'
    scaler_y_path = f'models/region/{region_name}_scaler_y.pkl'

    if not os.path.exists(model_path):
        print(f"[⚠️ 경고] {region_name} 지역 모델이 존재하지 않습니다.")
        return None

    try:
        # 모델 및 스케일러 로드
        model = load_model(model_path, custom_objects={'mse': tensorflow.keras.losses.MeanSquaredError()})
        scaler_X = joblib.load(scaler_X_path)
        scaler_y = joblib.load(scaler_y_path)

        # 전처리
        X_seq, _, _, _ = preprocess_lstm(region_df, sequence_length)
        if len(X_seq) == 0:
            print(f"[❌ 오류] {region_name} - 시퀀스 데이터 부족")
            return None

        last_sequence = X_seq[-1]
        predictions = []

        for _ in range(predict_months):
            input_seq = np.expand_dims(last_sequence, axis=0)
            pred_scaled = model.predict(input_seq, verbose=0)
            pred = scaler_y.inverse_transform(pred_scaled)[0][0]
            predictions.append(pred)

            # 다음 input 갱신
            new_input = last_sequence[-1].copy()
            new_input[0] = pred_scaled[0][0]  # 공급량이 첫 번째 피처라고 가정
            last_sequence = np.vstack([last_sequence[1:], new_input])

        return predictions

    except Exception as e:
        print(f"[예측 실패] {region_name}: {e}")
        return None
