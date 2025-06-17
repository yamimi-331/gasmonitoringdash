import matplotlib.pyplot as plt
import pandas as pd

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