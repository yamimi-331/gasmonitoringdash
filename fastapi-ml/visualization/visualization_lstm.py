import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
import sys
import os
# 루트 경로 추가
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from prediction.prediction_lstm import predict_lstm,predict_lstm_by_region

def plot_predictions(df, region_name, predictions, sequence_length=12):
    """
    지역별 실제 공급량 + LSTM 예측 결과 시각화

    Args:
        df: 전체 원본 데이터프레임
        region_name: 시각화할 지역명
        predictions: 예측값 리스트 (예: [132000, 128000, 130000])
        sequence_length: 시퀀스 길이 (기본: 12개월 → 예측 시작 기준점)
    """

    plt.rc('font', family='Malgun Gothic')  # 한글 깨짐 방지
    
    # 해당 지역 데이터만 추출
    region_df = df[df['Local'] == region_name].copy()
    region_df['Date'] = pd.to_datetime(region_df['Date'])

    # 최근 sequence_length 개월 + 예측 개월 수 만큼 사용
    region_df = region_df.sort_values('Date')
    recent_df = region_df.iloc[-sequence_length:].copy()

    # 예측할 날짜 생성 (마지막 날짜 기준 다음 달부터)
    last_date = recent_df['Date'].max()
    future_dates = pd.date_range(start=last_date + pd.DateOffset(months=1), periods=len(predictions), freq='MS')

    # 시각화용 데이터프레임 생성
    future_df = pd.DataFrame({
        'Date': future_dates,
        'GasSupply': predictions
    })

    # 시각화
    plt.figure(figsize=(10, 5))
    plt.plot(recent_df['Date'], recent_df['GasSupply'], label='실제 공급량', marker='o')
    plt.plot(future_df['Date'], future_df['GasSupply'], label='예측 공급량 (LSTM)', linestyle='--', marker='x', color='orange')

    plt.title(f"{region_name} - 실제 vs 예측 공급량")
    plt.xlabel("날짜")
    plt.ylabel("공급량")
    plt.grid(True)
    plt.legend()
    plt.tight_layout()
    plt.show()

def barplot_predictions(df, region_name, predictions, sequence_length=12):
    """
    지역별 실제 공급량 + LSTM 예측 결과를 막대그래프로 시각화

    Args:
        df: 전체 원본 데이터프레임
        region_name: 시각화할 지역명
        predictions: 예측값 리스트 (예: [132000, 128000, 130000])
        sequence_length: 시퀀스 길이 (기본: 12개월 → 예측 시작 기준점)
    """

    # 한글 폰트 설정 (윈도우용)
    plt.rc('font', family='Malgun Gothic')

    # 해당 지역 데이터만 추출
    region_df = df[df['Local'] == region_name].copy()
    region_df['Date'] = pd.to_datetime(region_df['Date'])

    # 최근 sequence_length 개월 실제 데이터
    region_df = region_df.sort_values('Date')
    recent_df = region_df.iloc[-sequence_length:].copy()

    # 예측할 날짜 생성 (마지막 날짜 기준 다음 달부터)
    last_date = recent_df['Date'].max()
    future_dates = pd.date_range(start=last_date + pd.DateOffset(months=1), periods=len(predictions), freq='MS')

    # 시각화용 데이터프레임 생성
    future_df = pd.DataFrame({
        'Date': future_dates,
        'GasSupply': predictions
    })

    # 막대 너비 및 위치 설정
    bar_width = 20  # 날짜가 datetime이므로 약간 넓게 잡음

    plt.figure(figsize=(12, 6))

    # 실제 데이터 막대 (파란색)
    plt.bar(recent_df['Date'], recent_df['GasSupply'], width=bar_width, label='실제 공급량')

    # 예측 데이터 막대 (주황색)
    plt.bar(future_df['Date'], future_df['GasSupply'], width=bar_width, label='예측 공급량 (LSTM)', color='orange')

    plt.title(f"{region_name} - 실제 vs 예측 공급량 (막대그래프)")
    plt.xlabel("날짜")
    plt.ylabel("공급량")
    plt.grid(axis='y')
    plt.legend()
    plt.tight_layout()
    plt.show()

def barplot_predictions_detail(df, region_name, predictions, sequence_length=12):
    """
    지역별 실제 공급량 + 과거 예측값 + LSTM 미래 예측 결과를 막대그래프로 시각화

    Args:
        df: 전체 원본 데이터프레임
        region_name: 시각화할 지역명
        predictions: 미래 예측값 리스트 (예: [132000, 128000, 130000])
        sequence_length: 시퀀스 길이 (기본: 12개월 → 과거 예측용 기준)
    """

    plt.rc('font', family='Malgun Gothic')

    # 해당 지역 데이터만 추출
    region_df = df[df['Local'] == region_name].copy()
    region_df['Date'] = pd.to_datetime(region_df['Date'])
    region_df = region_df.sort_values('Date').reset_index(drop=True)

    # 최근 sequence_length 개월 실제 데이터
    recent_df = region_df.iloc[-sequence_length:].copy()

    # 1) 과거 예측값 계산 (최근 sequence_length 개월 각각에 대해 1개월 뒤 예측)
    past_preds = []
    for i in range(len(region_df) - sequence_length, len(region_df)):
        # i번째 시점부터 sequence_length 개월 데이터 slice
        slice_df = region_df.iloc[i-sequence_length+1:i+1].copy()  # i 시점 포함 직전 sequence_length 개월 데이터
        if len(slice_df) < sequence_length:
            # 만약 데이터가 부족하면 0 또는 np.nan 등 처리
            past_preds.append(np.nan)
            continue

        # 여기에 1개월 예측 함수 호출 (predict_lstm이 1개월 예측 리턴하도록 수정 필요)
        pred_1month = predict_lstm_by_region(slice_df, region_name, sequence_length=sequence_length, predict_months=1)
        past_preds.append(pred_1month)

    # 2) 미래 예측 날짜 생성 (최근 데이터 마지막 날짜 이후부터)
    last_date = recent_df['Date'].max()
    future_dates = pd.date_range(start=last_date + pd.DateOffset(months=1), periods=len(predictions), freq='MS')
    future_df = pd.DataFrame({'Date': future_dates, 'GasSupply': predictions})

    # 막대 너비 설정
    bar_width = 20

    plt.figure(figsize=(14, 7))

    # 실제 데이터 막대 (파란색)
    plt.bar(recent_df['Date'], recent_df['GasSupply'], width=bar_width, label='실제 공급량')

    # 과거 예측값 막대 (반투명 주황, 실제 데이터 위에 겹치게)
    plt.bar(recent_df['Date'], past_preds, width=bar_width * 0.5, label='과거 예측 공급량', color='orange', alpha=0.7)

    # 미래 예측값 막대 (빨강)
    plt.bar(future_df['Date'], future_df['GasSupply'], width=bar_width, label='미래 예측 공급량', color='red')

    plt.title(f"{region_name} - 실제 vs 과거 예측 vs 미래 예측 공급량 (막대그래프)")
    plt.xlabel("날짜")
    plt.ylabel("공급량")
    plt.legend()
    plt.grid(axis='y')
    plt.tight_layout()
    plt.show()
