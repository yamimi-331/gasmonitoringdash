from fastapi import FastAPI, Query
from fastapi.middleware.cors import CORSMiddleware
import sys
import os
# 루트 경로 추가
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
import pandas as pd
import numpy as np

from prediction.prediction_lstm import get_prediction_json, evaluate_prediction_results
from prediction.prediction_xgboost import prediction_xgboost
from prediction.prediction_prophet import predict_prophet
from yearsupply import yearSupply
from population import populationSupply
from coldDaySupply import get_winter_gas_data
from temperature import get_winter_temp_data
from fastapi.responses import JSONResponse

# FastAPI 사용
app = FastAPI()

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

# 지역별 가스공급량 수요 예측 데이터 반환 lstm
@app.get("/api/gas/lstm-prediction")
async def get_lstm_prediction(
    local_name: str = Query(..., description="지역명"),
    future_months: int = Query(3, description="예측할 미래 개월 수"),
    recent_months: int = Query(6, description="최근 실제 데이터 개월 수"),
    sequence_length: int = Query(12, description="시퀀스 길이"),
):
    try:
        df = pd.read_excel("./data/GasData.xlsx")
        preds = get_prediction_json(df, local_name, future_months, recent_months, sequence_length)
        evaluation = evaluate_prediction_results(preds)

        response = {
            "local_name": local_name,
            "prediction_result": convert_all_numpy_to_builtin(preds),
            "evaluation": evaluation
        }
        return JSONResponse(response)
    except Exception as e:
       return JSONResponse(status_code=400, content={"error": str(e)})
    
# 지역별 가스공급량 수요 예측 데이터 반환 xgboost
@app.get("/api/gas/xgboost-prediction")
async def get_xgboost_prediction(
    local_name: str = Query(..., description="지역명"),
    start_date: str = Query(..., description="시작일자"),
    end_date: str = Query(..., description="종료일자"),
):
    try:
        df = pd.read_excel("./data/GasData.xlsx")
        preds = prediction_xgboost(df, start_date, end_date, local_name)
        evaluation = evaluate_prediction_results(preds)

        response = {
            "local_name": local_name,
            "prediction_result": convert_all_numpy_to_builtin(preds),
            "evaluation": evaluation
        }
        return JSONResponse(response)
    except Exception as e:
        return JSONResponse(status_code=400, content={"error": str(e)})

# 지역별 가스공급량 수요 예측 데이터 반환 Prophet
@app.get("/api/gas/prophet-prediction")
def predict(
    local_name: str = Query(..., description="지역명"),
    future_predict_months: int = Query(3, description="예측 개월 수"),
    recent_actual_months: int = Query(15, description="과거 보여줄 개월 수")
):
    try:
        df = pd.read_excel("./data/GasData.xlsx")
        preds = predict_prophet(df, local_name, future_predict_months, recent_actual_months)
        evaluation = evaluate_prediction_results(preds)
        response = {
            "local_name": local_name,
            "prediction_result": convert_all_numpy_to_builtin(preds),
            "evaluation": evaluation
        }
        return JSONResponse(response)
    except ValueError as e:
        return JSONResponse(status_code=400, content={"error": str(e)})

# 년도별 지역별 공급량 데이터 반환(JSON)
@app.get("/api/gas/yearsupply")
def get_year_supply(
    year: int = Query(2025, description="선택 연도"),
):
    try:
        df = pd.read_excel("./data/GasData.xlsx")
        result = yearSupply(df, year)
        cleaned_result = convert_all_numpy_to_builtin(result)
        return JSONResponse(cleaned_result)
    except ValueError as e:
        return JSONResponse(status_code=400, content={"error": str(e)})
    
# 인구수 & 공급량 데이터 반환(JSON)
@app.get("/api/gas/populationsupply")
def get_population_supply(
    localname: str = Query(..., description="선택 지역"),
):
    try:
        df = pd.read_excel("./data/GasData.xlsx")
        result = populationSupply(df, localname)
        cleaned_result = convert_all_numpy_to_builtin(result)
        return JSONResponse(cleaned_result)
    except ValueError as e:
        return JSONResponse(status_code=400, content={"error": str(e)})

# 한파일수 & 공급량 데이터 반환(JSON)
@app.get("/api/gas/coldDaySupply")
def get_coldDay_supply(
    localname: str = Query(..., description="선택 지역"),
    year: int = Query(2025, description="선택 연도")
):
    try:
        df = pd.read_excel("./data/GasData.xlsx")
        result = get_winter_gas_data(df, localname, year)
        cleaned_result = convert_all_numpy_to_builtin(result)
        return JSONResponse(cleaned_result)
    except ValueError as e:
        return JSONResponse(status_code=400, content={"error": str(e)})
    
# 한파일수 & 공급량 & 기온 데이터 반환(JSON)
@app.get("/api/gas/coldDayTempSupply")
def get_coldDay_Temp_supply(
    localname: str = Query(..., description="선택 지역"),
    year: int = Query(2025, description="선택 연도")
):
    try:
        df = pd.read_excel("./data/GasData.xlsx")
        result = get_winter_temp_data(df, localname, year)
        cleaned_result = convert_all_numpy_to_builtin(result)
        return JSONResponse(cleaned_result)
    except ValueError as e:
        return JSONResponse(status_code=400, content={"error": str(e)})