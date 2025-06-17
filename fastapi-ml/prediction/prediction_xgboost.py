import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_squared_error, r2_score
import xgboost as xgb
from sklearn.preprocessing import LabelEncoder
import joblib
import sys
import os
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from training.training_xgboost import training_xgboost
from visualization.visualization_xgboost import visualization_xgboost
import warnings
warnings.filterwarnings('ignore')

def prediction_xgboost(df, start_date, end_date, local_name=None):
    """
    XGBoost 데이터 예측
    """
    xgb_model = joblib.load("models/model_xgboost.pkl")
    le = joblib.load("models/xgboost_label_encoder.pkl")

    # 날짜 문자열 정렬하기
    df = df.copy()
    df['Date'] = pd.to_datetime(df['Date'])
    df['Local'] = le.transform(df['Local'])
    df['YearMonth'] = df['Date'].dt.to_period('M').astype(str)
    # 날짜 범위 지정
    date_range = pd.date_range(start=start_date, end=end_date, freq='MS')

    if local_name is not None:
        region_encoded = le.transform([local_name])[0]
        locals_encoded = [region_encoded]
    else:
        locals_encoded = df['Local'].unique()

    # 최근 12개월 평균 특성
    recent_data = df[df['Date'] >= (df['Date'].max() - pd.DateOffset(months=11))]
    recent_data['Month'] = recent_data['Date'].dt.month

    monthly_avg = recent_data.groupby(['Local', 'Month'])[['Temperature', 'Humidity', 'Population']].mean()
    # 인덱스를 컬럼으로 변환
    monthly_avg = monthly_avg.reset_index()

    X_pred_list = []
    pred_info = []
    # 예측 날짜 범위 순회
    for date_obj in date_range:
        date_ord = date_obj.toordinal()
        month = date_obj.month

        for local_encoded in locals_encoded:
            monthly_avg_row = monthly_avg[(monthly_avg['Local'] == local_encoded)&(monthly_avg['Month'] == month)]
            if monthly_avg_row.empty:
                temp, hum, pop = 0, 0, 0
            else:
                temp = monthly_avg_row['Temperature'].values[0]
                hum = monthly_avg_row['Humidity'].values[0]
                pop = monthly_avg_row['Population'].values[0]

        X_pred_list.append([date_ord, local_encoded, temp, hum, pop])
        pred_info.append((local_encoded, str(date_obj.to_period('M')), date_obj))

    # XGBoost에 입력할 수 있게 리스트
    X_pred_xgb = np.array(X_pred_list)
    # 예측 수행
    y_pred_xgb = xgb_model.predict(X_pred_xgb)

    pred_df = pd.DataFrame(pred_info, columns=['Local', 'YearMonth', 'Date'])
    pred_df['Predicted_GasSupply'] = y_pred_xgb
    # 디코딩용 역변환
    pred_df['LocalName'] = le.inverse_transform(pred_df['Local'])

    json_str = visualization_xgboost(df, pred_df, local_name, le, start_date, end_date)
        
    return json_str
    
