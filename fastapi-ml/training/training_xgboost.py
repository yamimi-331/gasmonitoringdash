import pandas as pd
import numpy as np
import xgboost as xgb
import joblib
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_squared_error, r2_score
# 루트 경로 추가
import sys
import os
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from preprocessing.preprocessing_xgboost import preprocess_xgboost

def training_xgboost(df):
    """
    XGBoost 데이터 학습
    """
    X_xgb, Y_xgb, le, df = preprocess_xgboost(df)
    X_train_xgb, X_test_xgb, Y_train_xgb, Y_test_xgb = train_test_split(X_xgb, Y_xgb, test_size=0.2, random_state=42)

    # XGBoost 분류기 모델 객체
    xgb_model = xgb.XGBRegressor(
            n_estimators=100,
            learning_rate=0.1,
            max_depth=5,
            random_state=42
        )

    xgb_model.fit(X_train_xgb, Y_train_xgb)
    xgb_pred = xgb_model.predict(X_test_xgb)

    # 모델 평가
    xgb_mse = mean_squared_error(Y_test_xgb, xgb_pred)
    xgb_rmse = np.sqrt(xgb_mse)
    xgb_r2 = r2_score(Y_test_xgb, xgb_pred)

    # 딕셔너리로 반환
    xgb_results = {"XGBoost":{ 
            'model': xgb_model,
            'le': le,
            'mse': xgb_mse,
            'rmse': xgb_rmse,
            'r2': xgb_r2,
            'X_test': X_test_xgb,
            'y_test': Y_test_xgb,
            'df': df}
        }
    
    os.makedirs('models', exist_ok=True)
    joblib.dump(xgb_model, 'models/model_xgboost.pkl')
    joblib.dump(le, f'models/xgboost_label_encoder.pkl')


# if __name__ == "__main__":
#     # 여기에 재학습할 데이터셋 파일 경로 입력
#     excel_path = "./data/GasData.xlsx"

#     # 데이터 로드
#     df = pd.read_excel(excel_path)

#     # 재학습 실행
#     training_xgboost(df)