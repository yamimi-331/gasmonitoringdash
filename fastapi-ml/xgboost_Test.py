
import pandas as pd
import sys
import os
# 루트 경로 추가
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from training.training_xgboost import training_xgboost
from prediction.prediction_xgboost import prediction_xgboost
from visualization.visualization_xgboost import visualization_xgboost

if __name__ == "__main__":
    df = pd.read_excel("./data/GasData.xlsx")
    xgb_results = training_xgboost(df)

    local_name = "강원특별자치도"
    preds = prediction_xgboost(df, xgb_results, '2020-01-01', '2025-06-01', local_name)

    # ✅ DataFrame이 비어 있지 않은지 확인
    if not preds.empty:
        le = xgb_results['XGBoost']['le']
        visualization_xgboost(df, preds, local_name, le, start_date='2024-01-01', end_date='2025-06-01')
    else:
        print("❗ 예측 결과가 비어 있습니다.")
