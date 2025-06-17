# lstm 예측 코드 테스트용 
# test_lstm_predict.py
import pandas as pd
import numpy as np
import json
import sys
import os
# 루트 경로 추가
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
# 전처리 
from preprocessing.preprocessing_lstm import preprocess_lstm_by_region, preprocess_lstm
# 훈련 모델
from training.training_lstm import train_lstm,train_lstm_by_region
# 예측 함수
from prediction.prediction_lstm import predict_lstm,predict_lstm_by_region,get_prediction_json
# 시각화 함수
from visualization.visualization_lstm import plot_predictions,barplot_predictions,barplot_predictions_detail

if __name__ == "__main__":
    # 엑셀 데이터 로딩
    df = pd.read_excel("./data/GasData.xlsx")
   
    region_name = "강원특별자치도"
        
    def convert_np_to_builtin(obj):
        if isinstance(obj, (np.int64, np.int32)):
            return int(obj)
        elif isinstance(obj, (np.float32, np.float64)):
            return float(obj)
        raise TypeError(f"Object of type {type(obj).__name__} is not JSON serializable")

    future_predict_months = 3
    recent_actual_months = 6
    sequence_length = 12
    # 예측 결과 JSON 얻기
    result_json = get_prediction_json(df, region_name, future_predict_months, recent_actual_months, sequence_length)

    print(json.dumps(result_json, indent=4, ensure_ascii=False, default=convert_np_to_builtin))
