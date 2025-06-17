import pandas as pd
import json
import matplotlib.pyplot as plt
import seaborn as sns
import io
import base64
import matplotlib.dates as mdates

def visualization_xgboost(df, pred_df, local_name, le, start_date=None, end_date=None):
    """
    지역별 실제 vs 예측 가스 공급량 (월별) 시각화
    - df: 실제 데이터셋
    - pred_df: prediction_xgboost 결과
    - local_name: 시각화 대상 지역
    """
    plt.rc('font', family='Malgun Gothic') 

    df = df.copy()
    pred_df = pred_df.copy()

    # 연월 컬럼 추가
    df['YearMonth'] = df['Date'].dt.to_period('M').astype(str)
    pred_df['YearMonth'] = pred_df['Date'].dt.to_period('M').astype(str)

    try:
        local_encoded = le.transform([local_name])[0]
    except Exception as e:
        print(f"Error encoding local_name '{local_name}': {e}")
        return

    # 선택 지역 필터링
    df_local = df[df['Local'] == local_encoded]
    pred_local = pred_df[pred_df['Local'] == local_encoded]

    # 날짜 필터링 (Date 컬럼 기준)
    if start_date:
        start_date = pd.to_datetime(start_date)
        df_local = df_local[df_local['Date'] >= start_date]
        pred_local = pred_local[pred_local['Date'] >= start_date]
    if end_date:
        end_date = pd.to_datetime(end_date)
        df_local = df_local[df_local['Date'] <= end_date]
        pred_local = pred_local[pred_local['Date'] <= end_date]
    
    # 연 월 문자열 생성
    df_local['YearMonth'] = df_local['Date'].dt.strftime('%Y-%m')
    pred_local['YearMonth'] = pred_local['Date'].dt.strftime('%Y-%m')

    # 실제 월별 가스 공급량
    actual_monthly = df_local.groupby('YearMonth')['GasSupply'].sum().reset_index()
    # 예측 월별 가스 공급량
    pred_monthly = pred_local.groupby('YearMonth')['Predicted_GasSupply'].mean().reset_index()

    # YearMonth를 datetime으로 변환 (각 월의 첫 날로)
    actual_monthly['YearMonth_dt'] = pd.to_datetime(actual_monthly['YearMonth'])
    pred_monthly['YearMonth_dt'] = pd.to_datetime(pred_monthly['YearMonth'])

    #Json 변환용 리스트
    all_months = set(actual_monthly['YearMonth']) | set(pred_monthly['YearMonth'])
    actual_series = actual_monthly.set_index('YearMonth')['GasSupply']
    pred_series = pred_monthly.set_index('YearMonth')['Predicted_GasSupply']
    result_dict = {}

    for ym in sorted(all_months):
        actual_raw = actual_series.get(ym, None)
        pred_raw = pred_series.get(ym, None)

        # NaN 값을 None으로 변환
        actual = None if pd.isna(actual_raw) else float(actual_raw)
        pred = None if pd.isna(pred_raw) else float(pred_raw)

        # 모두 None인 경우는 제외하지 말고 포함
        result_dict[ym] = {
        "actual": actual,
        "past_pred": pred if ym in actual_series else None,
        "future_pred": pred if ym not in actual_series else None
        }


    # # 그래프 그리기
    # plt.figure(figsize=(16, 7))
    # # sns.barplot(data=plot_df, x='YearMonth', y='Value', hue='Type', palette={'실제': 'dodgerblue', '예측': 'skyblue'})
    # plt.fill_between(actual_monthly['YearMonth_dt'], actual_monthly['GasSupply'], color='dodgerblue', alpha=0.4, label='실제')
    # plt.plot(actual_monthly['YearMonth_dt'], actual_monthly['GasSupply'], color='dodgerblue')

    # plt.fill_between(pred_monthly['YearMonth_dt'], pred_monthly['Predicted_GasSupply'], color='skyblue', alpha=0.4, label='예측')
    # plt.plot(pred_monthly['YearMonth_dt'], pred_monthly['Predicted_GasSupply'], color='skyblue')

    # # x축 눈금 위치와 레이블 설정
    # ax = plt.gca()
    # ax.xaxis.set_major_locator(mdates.MonthLocator(interval=2))  # 2개월 간격
    # ax.xaxis.set_major_formatter(mdates.DateFormatter('%Y-%m'))   # '2024-06' 형태
    # if start_date is not None and end_date is not None:
    #     ax.set_xlim(pd.to_datetime(start_date), pd.to_datetime(end_date))
    # ax.set_ylim(bottom=0)

    # plt.xticks(rotation=60, ha='right', fontsize=9)
    # plt.title(f'가스 공급량 예측 vs 실제 ({local_name})', fontsize=16)
    # plt.xlabel('연월')
    # plt.ylabel('가스 공급량')
    # plt.legend(title='데이터 유형')
    # plt.grid(axis='y', linestyle='--', alpha=0.5)
    # plt.tight_layout()

    # plt.show()
    # # 이미지로 반환
    # buf = io.BytesIO()
    # plt.savefig(buf, format='png')
    # plt.close()
    # buf.seek(0)
    # encoded_img = base64.b64encode(buf.read()).decode('utf-8')

    return result_dict
