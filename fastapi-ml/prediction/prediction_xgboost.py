import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_squared_error, r2_score
import xgboost as xgb
from sklearn.preprocessing import LabelEncoder
import sys
import os
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from training.training_xgboost import training_xgboost
import warnings
warnings.filterwarnings('ignore')

def prediction_xgboost(df, results, start_date, end_date, local_name=None):
    """
    XGBoost 데이터 예측
    """
    # XGBoost 모델 가져오기
    xgb_model = results['XGBoost']['model']
    xgb_le = results['XGBoost']['le']

    # 날짜 문자열 정렬하기
    df = df.copy()
    df['YearMonth'] = df['Date'].dt.to_period('M').astype(str)
    # 날짜 범위 지정
    date_range = pd.date_range(start=start_date, end=end_date, freq='MS')

    locals_encoded = df['Local'].unique() # 인코딩된 지역 코드 사용
    le_inverse_map = {v: k for k, v in dict(zip(df['Local'], df['Local'])).items()}

    # 최근 12개월 평균 특성
    recent_data = df[df['Date'] >= (df['Date'].max() - pd.DateOffset(months=11))]
    monthly_avg = recent_data.groupby(recent_data['Date'].dt.month)[['Temperature', 'Humidity', 'Population']].mean()

    X_pred_list = []
    pred_info = []
    # 예측 날짜 범위 순회
    for date_obj in date_range:
        date_ord = date_obj.toordinal()
        month = date_obj.month

        temp = monthly_avg.loc[month, 'Temperature']
        hum = monthly_avg.loc[month, 'Humidity']
        pop = monthly_avg.loc[month, 'Population']

        for local_encoded in locals_encoded:
            X_pred_list.append([date_ord, local_encoded, temp, hum, pop])
            pred_info.append((local_encoded, str(date_obj.to_period('M')), date_obj))

    # XGBoost에 입력할 수 있게 리스트
    X_pred_xgb = np.array(X_pred_list)
    # 예측 수행
    y_pred_xgb = xgb_model.predict(X_pred_xgb)

    pred_df = pd.DataFrame(pred_info, columns=['Local', 'YearMonth', 'Date'])
    pred_df['Predicted_GasSupply'] = y_pred_xgb

    if local_name is not None:
        region_encoded = xgb_le.transform([local_name])[0]
        pred_df = pred_df[pred_df['Local'] == region_encoded]
    
    return pred_df
    
