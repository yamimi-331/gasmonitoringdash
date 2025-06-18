from prophet import Prophet
import pandas as pd
import numpy as np

def predict_prophet(df: pd.DataFrame, local_name: str, future_predict_months: int = 3, recent_actual_months: int = 15) -> dict:
    # 1. 날짜 처리 및 지역 필터링
    df['Date'] = pd.to_datetime(df['Date'], format="%m/%d/%y")
    df['YearMonth'] = df['Date'].dt.to_period("M").dt.to_timestamp()

    filtered = df[df['Local'] == local_name].copy()
    if filtered.empty:
        raise ValueError(f"'{local_name}' 지역에 대한 데이터가 없습니다.")

    # 2. 월별 집계
    monthly = filtered.groupby('YearMonth').agg({'GasSupply': 'sum'}).reset_index()
    monthly.rename(columns={"YearMonth": "ds", "GasSupply": "y"}, inplace=True)

    # 3. Prophet 모델 학습
    model = Prophet()
    model.fit(monthly)

    # 4. 미래 데이터 프레임 생성
    future = model.make_future_dataframe(periods=future_predict_months, freq='MS')
    forecast = model.predict(future)[['ds', 'yhat']]

    # 5. 병합
    combined = pd.merge(forecast, monthly, on='ds', how='left')
    combined['ds'] = combined['ds'].dt.strftime('%Y-%m')
    combined.set_index('ds', inplace=True)

    # 6. 마지막 실제 데이터 날짜 구하기
    last_real_date = monthly['ds'].max().strftime('%Y-%m')
    start_show_date = pd.to_datetime(last_real_date) - pd.DateOffset(months=recent_actual_months - 1)
    start_show_str = start_show_date.strftime('%Y-%m')

    # 7. JSON 포맷 만들기
    result = {}
    for idx, row in combined.iterrows():
        if idx < start_show_str:
            continue

        actual = row['y'] if not pd.isna(row['y']) else None
        predicted = round(row['yhat']) if not pd.isna(row['yhat']) else None

        # 실제값과 예측값이 모두 없으면 건너뜀
        if actual is None and predicted is None:
            continue

        entry = {"actual": actual, "past_pred": None, "future_pred": None}
        if actual is not None:
            entry["past_pred"] = predicted
        elif idx > last_real_date:
            entry["future_pred"] = predicted
        result[idx] = entry

    return result