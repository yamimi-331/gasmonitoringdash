# ✅ 필요한 라이브러리 임포트
import numpy as np
import pandas as pd
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import LSTM, Dense, Dropout
from tensorflow.keras.callbacks import EarlyStopping
from sklearn.model_selection import train_test_split
import joblib  # 모델 저장용
import sys
import os

# 루트 경로 추가
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from preprocessing.preprocessing_lstm import preprocess_lstm, preprocess_lstm_by_region  # 전처리 함수 임포트

# LSTM 모델 학습 함수
def train_lstm(df, sequence_length=12, epochs=50, batch_size=32):
    """
    LSTM 모델을 학습시키고 저장하는 함수
    """
    #  전처리 수행 (시퀀스 생성 및 정규화 포함)
    X_seq, y_seq, scaler_X, scaler_y = preprocess_lstm(df, sequence_length)

    # 학습/검증 데이터 분할
    X_train, X_val, y_train, y_val = train_test_split(
        X_seq, y_seq, test_size=0.2, shuffle=False  # 시계열이므로 셔플 X
    )

    # LSTM 모델 구성
    model = Sequential()
    model.add(LSTM(64, activation='relu', input_shape=(X_train.shape[1], X_train.shape[2])))
    model.add(Dropout(0.2))  # 과적합 방지용 Dropout
    model.add(Dense(1))  # 출력층 (예측값 1개)

    # 컴파일
    model.compile(optimizer='adam', loss='mse')

    # 학습 (EarlyStopping 포함)
    early_stop = EarlyStopping(monitor='val_loss', patience=5, restore_best_weights=True)
    model.fit(
        X_train, y_train,
        validation_data=(X_val, y_val),
        epochs=epochs,
        batch_size=batch_size,
        callbacks=[early_stop],
        verbose=1
    )

    # 🔹 모델 및 스케일러 저장
    model.save('models/models_lstm.h5')  # 모델 저장
    joblib.dump(scaler_X, 'models/lstm_scaler_X.pkl')
    joblib.dump(scaler_y, 'models/lstm_scaler_y.pkl')

    print("LSTM 모델 학습 및 저장 완료!")

    return model

# 지역별 모델생성
def train_lstm_by_region(df, sequence_length=12):
    region_data = preprocess_lstm_by_region(df, sequence_length)

    for region, data in region_data.items():
        X_seq = data['X_seq']
        y_seq = data['y_seq']
        scaler_X = data['scaler_X']
        scaler_y = data['scaler_y']

        if len(X_seq) == 0:
            print(f"[Skip] {region} - 데이터 부족")
            continue

        # 모델 정의
        model = Sequential([
            LSTM(64, input_shape=X_seq.shape[1:]),
            Dense(1)
        ])
        model.compile(optimizer='adam', loss='mse')

        # 학습
        model.fit(X_seq, y_seq, epochs=30, batch_size=16, verbose=1)

        # 저장 경로
        os.makedirs('models/region', exist_ok=True)
        model.save(f'models/region/{region}_lstm.h5')
        joblib.dump(scaler_X, f'models/region/{region}_scaler_X.pkl')
        joblib.dump(scaler_y, f'models/region/{region}_scaler_y.pkl')

        print(f"{region} 학습 및 저장 완료")
