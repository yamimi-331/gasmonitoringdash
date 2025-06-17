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
from prediction.prediction_lstm import predict_lstm,predict_lstm_by_region,get_prediction_json,get_prediction_json3
# 시각화 함수
from visualization.visualization_lstm import plot_predictions,barplot_predictions,barplot_predictions_detail

if __name__ == "__main__":
    # 엑셀 데이터 로딩
    df = pd.read_excel("./data/GasData.xlsx")
    # 학습 진행 
    # 데이터 확인 (옵션)
    #print(df.head())

    # train_lstm 함수 실행
    #model = train_lstm(df, sequence_length=12, epochs=10, batch_size=16)
    # 2. 학습 실행
    # train_lstm_by_region(df, sequence_length=12)
    #print("생성완료")
    #  예측 실행
    # predictions = predict_lstm(df, sequence_length=12, predict_months=3)
    region_name = "강원특별자치도"
    # preds = predict_lstm_by_region(df, region_name)

    # # 결과 출력
    # if preds:
        # plot_predictions(df, region_name, preds)    # 점선으로 이루어진 그래프
        # barplot_predictions(df, region_name, preds) # 막대그래프
        # barplot_predictions_detail(df, region_name, preds)
    # print("📊 LSTM 미래 공급량 예측 (3개월):")
    # for i, val in enumerate(predictions, 1):
    #     print(f"{i}개월 후 예측 공급량: {val:.2f}")
        
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
    result_json = get_prediction_json3(df, region_name, future_predict_months, recent_actual_months, sequence_length)

    # None 값은 JSON 직렬화에서 null로 바뀜. 보기 편하게 indent 추가해서 출력
    print(json.dumps(result_json, indent=4, ensure_ascii=False, default=convert_np_to_builtin))
