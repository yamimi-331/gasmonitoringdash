# lstm 예측 코드 테스트용 
# test_lstm_predict.py
import pandas as pd
import sys
import os
# 루트 경로 추가
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from training.training_lstm import train_lstm,train_lstm_by_region
from prediction.prediction_lstm import predict_lstm,predict_lstm_by_region
from visualization.visualization_lstm import plot_predictions,barplot_predictions

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
    preds = predict_lstm_by_region(df, region_name)

    # # 결과 출력
    if preds:
        plot_predictions(df, region_name, preds)    # 점선으로 이루어진 그래프
        barplot_predictions(df, region_name, preds) # 막대그래프
    
    # print("📊 LSTM 미래 공급량 예측 (3개월):")
    # for i, val in enumerate(predictions, 1):
    #     print(f"{i}개월 후 예측 공급량: {val:.2f}")
