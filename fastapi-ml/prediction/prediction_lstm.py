# ✅ 필요한 라이브러리
import numpy as np
import pandas as pd
import joblib
from tensorflow.keras.models import load_model
import tensorflow.keras.losses
from pandas.tseries.offsets import DateOffset
import sys
import os

# 루트 경로 추가
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from preprocessing.preprocessing_lstm import prepare_data_for_single_prediction  # 전처리 함수 불러오기

# 지우지마
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

    # 해당 지역 데이터만 필터링
    region_df = df[df['Local'] == region_name].copy()

    if region_df.empty:
        print(f"[오류] {region_name} 지역 데이터 없음")
        return None

    # 모델 및 스케일러 경로
    model_path = f'models/region/{region_name}_lstm.h5'
    scaler_X_path = f'models/region/{region_name}_scaler_X.pkl'
    scaler_y_path = f'models/region/{region_name}_scaler_y.pkl'
    le_path = f'models/region/{region_name}_label_encoder.pkl'

    if not os.path.exists(model_path):
        print(f"[⚠️ 경고] {region_name} 지역 모델이 존재하지 않습니다.")
        return None

    try:
        # 모델 및 스케일러 로드
        model = load_model(model_path, custom_objects={'mse': tensorflow.keras.losses.MeanSquaredError()})
        scaler_X = joblib.load(scaler_X_path)
        scaler_y = joblib.load(scaler_y_path)
        le = joblib.load(le_path)
        # 전처리
        region_df = region_df.sort_values('Date') 
        
        if len(region_df) < sequence_length:
            print(f"[❌ 오류] {region_name} - 데이터가 {sequence_length}개월보다 적음 ({len(region_df)}개월)")
            return None
        current_sequence_df = region_df.iloc[-sequence_length:].copy()
        initial_X_prepared = prepare_data_for_single_prediction(current_sequence_df, scaler_X, le, sequence_length)
        if initial_X_prepared is None or initial_X_prepared.shape[0] == 0:
            print(f"[❌ 오류] {region_name} - 초기 시퀀스 데이터 전처리 실패 또는 시퀀스 부족")
            return None
         # X_seq는 더 이상 사용하지 않고, initial_X_prepared를 바로 last_sequence_features로 사용합니다.
        last_sequence_features = initial_X_prepared[0] # (sequence_length, features) 형태

        predictions = []

        for _ in range(predict_months):
            input_seq = np.expand_dims(last_sequence_features, axis=0)
            pred_scaled = model.predict(input_seq, verbose=0)
            pred = scaler_y.inverse_transform(pred_scaled)[0][0]
            predictions.append(pred)

            # 다음 input 갱신
            new_input = last_sequence_features[-1].copy()
            new_input[0] = pred_scaled[0][0]  # 공급량이 첫 번째 피처라고 가정
            last_sequence_features = np.vstack([last_sequence_features[1:], new_input])

        return predictions

    except Exception as e:
        print(f"[예측 실패] {region_name}: {e}")
        return None
# 지우지마
def is_continuous_monthly(df_dates):
    """
    날짜 Series가 월 단위로 연속적인지 확인합니다.
    """
    if len(df_dates) <= 1:
        return True # 데이터가 없거나 하나면 연속으로 간주
    for i in range(1, len(df_dates)):
        prev = df_dates.iloc[i-1]
        curr = df_dates.iloc[i]
        expected_next = prev + pd.DateOffset(months=1)
        if curr.year != expected_next.year or curr.month != expected_next.month:
            return False
    return True

# 지우지마
def get_prediction_json(df, region_name, future_predict_months=3, recent_actual_months=9, sequence_length=12):
    """
    실제 데이터 + 과거 예측 + 미래 예측 데이터를 날짜별로 묶어 JSON 형태로 반환

    Args:
        df: 원본 데이터프레임 (Local 포함, Date 컬럼 포함)
        region_name: 지역명 (예: '서울')
        future_predict_months: 미래 예측 개월 수 (기본 3개월)
        recent_actual_months: 최근 실제 데이터 개월 수 (기본 9개월)
        sequence_length: LSTM 시퀀스 길이 (기본 12)

    Returns:
        dict: { 'YYYY-MM': {'actual': 값, 'past_pred': 값, 'future_pred': 값 or None}, ... }
    """

    # 1) 해당 지역 데이터 정리
    region_df = df[df['Local'] == region_name].copy()
    if region_df.empty:
        print(f"[오류] {region_name} 지역 데이터 없음")
        return None

    region_df['Date'] = pd.to_datetime(region_df['Date'])
    region_df = region_df.sort_values('Date').reset_index(drop=True)

    # # **여기서 전체 데이터의 연속성 및 길이 다시 확인**
    # if not is_continuous_monthly(region_df['Date']):
    #     print(f"[경고] {region_name} 지역의 전체 데이터가 월 단위로 연속적이지 않습니다.")
        
    
    if len(region_df) < sequence_length + recent_actual_months:
        print(f"[경고] {region_name} 지역의 데이터 길이가 충분하지 않습니다. (현재 {len(region_df)}개, 최소 {sequence_length + recent_actual_months}개 필요)")
        

    # 2) `past_preds` 초기화 및 계산 (최근 actual months 기간에 대한 과거 시점 예측)
    past_preds = []
    
    # 최근 `recent_actual_months`에 해당하는 각 월을 예측하기 위한 시퀀스 생성
    # 예: last_date가 2024-12 이고 recent_actual_months=9 이면
    # 2024-12월 예측 -> 시퀀스 2023-12 ~ 2024-11 사용
    # 2024-11월 예측 -> 시퀀스 2023-11 ~ 2024-10 사용
    # ...
    # 2024-04월 예측 -> 시퀀스 2023-04 ~ 2024-03 사용
    recent_actual_df = region_df.iloc[-recent_actual_months:].copy()
    # 예측 대상 월의 리스트 (가장 오래된 월부터 최신 월까지 순서대로)
    # last_date는 region_df의 가장 마지막 날짜 (예: 2024-12-01)
    # recent_actual_df는 마지막 9개월 (예: 2024-04-01 ~ 2024-12-01)

    # past_preds의 길이는 recent_actual_months와 동일하게 유지되어야 함
    # recent_actual_df에 있는 각 날짜에 대한 예측을 수행
    
    # recent_actual_df에 있는 각 날짜(d_idx)에 대해,
    # 해당 날짜를 예측하기 위해 사용해야 할 시퀀스는 d_idx - sequence_length 부터 d_idx - 1 까지의 데이터
    
    for i in range(len(recent_actual_df)):
        # 예측하려는 실제 월 (recent_actual_df의 i번째 월)
        target_month_for_past_pred = recent_actual_df.iloc[i]['Date']

        # 이 월을 예측하기 위한 시퀀스의 마지막 날짜는 target_month_for_past_pred의 직전 월
        seq_end_date = target_month_for_past_pred - pd.DateOffset(months=1)
        seq_start_date = seq_end_date - pd.DateOffset(months=sequence_length - 1)

        # 해당하는 슬라이스 추출
        slice_df = region_df[(region_df['Date'] >= seq_start_date) & (region_df['Date'] <= seq_end_date)].copy()

        pred_val = None # 기본값 None
        if len(slice_df) < sequence_length:
            print(f"[❌ 오류] {region_name} - 시퀀스 데이터 부족 (과거 예측 대상 {target_month_for_past_pred.strftime('%Y-%m')}, 길이 {len(slice_df)} < {sequence_length})")
        elif not is_continuous_monthly(slice_df['Date']):
            print(f"[❌ 오류] {region_name} - 시퀀스 데이터 비연속적 (과거 예측 대상 {target_month_for_past_pred.strftime('%Y-%m')})")
        else:
            try:
                # predict_lstm_by_region이 단일 값을 담은 리스트를 반환한다고 가정
                preds = predict_lstm_by_region(slice_df, region_name, sequence_length=sequence_length, predict_months=1)
                pred_val = preds[0] if isinstance(preds, list) and preds else None
            except Exception as e:
                print(f"[오류] {region_name} - 과거 예측 중 에러 발생 ({target_month_for_past_pred.strftime('%Y-%m')}): {e}")
                pred_val = None # 에러 발생 시 None 처리
        
        past_preds.append(pred_val)

    # 4) 미래 예측값 (최근 시퀀스 데이터로부터)
    # 미래 예측은 항상 region_df의 마지막 sequence_length 데이터를 사용하여 수행됩니다.
    # 만약 region_df의 길이가 sequence_length보다 짧으면 미래 예측도 어려움.
    future_preds_input_df = region_df.iloc[-sequence_length:].copy()
    
    future_preds = []
    if len(future_preds_input_df) < sequence_length:
        print(f"[❌ 오류] {region_name} - 미래 예측을 위한 시퀀스 데이터 부족 (길이 {len(future_preds_input_df)} < {sequence_length})")
        future_preds = [None] * future_predict_months
    elif not is_continuous_monthly(future_preds_input_df['Date']):
        print(f"[❌ 오류] {region_name} - 미래 예측을 위한 시퀀스 데이터 비연속적")
        future_preds = [None] * future_predict_months
    else:
        try:
            # predict_lstm_by_region은 여러 달 예측 가능
            preds_multi = predict_lstm_by_region(future_preds_input_df, region_name, sequence_length=sequence_length, predict_months=future_predict_months)
            future_preds = preds_multi if isinstance(preds_multi, list) else [None] * future_predict_months
            if not future_preds: # 빈 리스트인 경우
                 future_preds = [None] * future_predict_months
        except Exception as e:
            print(f"[오류] {region_name} - 미래 예측 중 에러 발생: {e}")
            future_preds = [None] * future_predict_months


    # 5) 날짜별로 결과 묶기
    result = {}

    for i, date_str in enumerate(recent_actual_df['Date'].dt.strftime('%Y-%m').tolist()):
        result[date_str] = {
            'actual': recent_actual_df.iloc[i]['GasSupply'],
            'past_pred': past_preds[i] if i < len(past_preds) else None,
            'future_pred': None # 이 기간은 미래 예측이 아니므로 None (past_pred가 해당 월의 예측값)
        }

    # 미래 예측 날짜 (last_actual_date 다음 달부터)
    last_actual_date = region_df['Date'].max() # region_df의 가장 마지막 실제 날짜
    future_dates = pd.date_range(start=last_actual_date + pd.DateOffset(months=1), periods=future_predict_months, freq='MS')
    
    for i, future_date_obj in enumerate(future_dates):
        date_str = future_date_obj.strftime('%Y-%m')
        result[date_str] = {
            'actual': None, # 미래 예측은 실제 데이터가 없음
            'past_pred': None, # 과거 예측도 아님
            'future_pred': future_preds[i] if i < len(future_preds) else None
        }

    return result