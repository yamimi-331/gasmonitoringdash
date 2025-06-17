from fastapi import FastAPI, Query
from fastapi.middleware.cors import CORSMiddleware
import sys
import os
# 루트 경로 추가
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
import pandas as pd
import numpy as np

from prediction.prediction_lstm import get_prediction_json
from prediction.prediction_xgboost import prediction_xgboost

app = FastAPI()

from fastapi.responses import JSONResponse

# JSON 타입 변환
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


# CORS 설정 - Spring 서버(8080)와 FastAPI 서버 간 통신
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:8080"],  # Spring 서버 주소
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE"],
    allow_headers=["*"],
)

@app.get("/api/gas/lstm-prediction")
async def get_lstm_prediction(
    region: str = Query(..., description="지역명"),
    future_months: int = Query(3, description="예측할 미래 개월 수"),
    recent_months: int = Query(6, description="최근 실제 데이터 개월 수"),
    sequence_length: int = Query(12, description="시퀀스 길이"),
):
    try:
        df = pd.read_excel("./data/GasData.xlsx")
        result = get_prediction_json(df, region, future_months, recent_months, sequence_length)
        cleaned_result = convert_all_numpy_to_builtin(result)
        return JSONResponse(cleaned_result)
    except Exception as e:
        return {"error": str(e)}
    
@app.get("/api/gas/xgboost-prediction")
async def get_xgboost_prediction(
    local_name: str = Query(..., description="지역명"),
    start_date: str = Query(..., description="시작일자"),
    end_date: str = Query(..., description="종료일자"),
):
    try:
        df = pd.read_excel("./data/GasData.xlsx")
        preds = prediction_xgboost(df, start_date, end_date, local_name)
        cleaned_result = convert_all_numpy_to_builtin(preds)
        return JSONResponse(cleaned_result)
    except Exception as e:
        return {"error": str(e)}
