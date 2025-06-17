
import pandas as pd
import numpy as np
import sys
import os
import json
# 루트 경로 추가
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from training.training_xgboost import training_xgboost
from prediction.prediction_xgboost import prediction_xgboost
from visualization.visualization_xgboost import visualization_xgboost

if __name__ == "__main__":
    df = pd.read_excel("./data/GasData.xlsx")
    # xgb_results = training_xgboost(df)

    local_name = "강원특별자치도"
    preds = prediction_xgboost(df, '2020-01-01', '2025-06-01', local_name)
    
    def convert_np_to_builtin(obj):
        if isinstance(obj, (np.int64, np.int32)):
            return int(obj)
        elif isinstance(obj, (np.float32, np.float64)):
            return float(obj)
        raise TypeError(f"Object of type {type(obj).__name__} is not JSON serializable")
    def convert_all_numpy_to_builtin(obj):
        if isinstance(obj, dict):
            return {k: convert_all_numpy_to_builtin(v) for k, v in obj.items()}
        elif isinstance(obj, list):
            return [convert_all_numpy_to_builtin(v) for v in obj]
        elif isinstance(obj, np.integer):
            return int(obj)
        elif isinstance(obj, np.floating):
            return float(obj)
        elif isinstance(obj, np.ndarray):
            return obj.tolist()
        else:
            return obj

    print(json.dumps(preds, indent=4, ensure_ascii=False, default=convert_all_numpy_to_builtin))

    # # ✅ DataFrame이 비어 있지 않은지 확인
    # if not preds.empty:
    #     le = xgb_results['XGBoost']['le']
    #     json_str = visualization_xgboost(df, preds, local_name, le, start_date='2024-01-01', end_date='2025-06-01')
    #     print(json_str)
    # else:
    #     print("❗ 예측 결과가 비어 있습니다.")
