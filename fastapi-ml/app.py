from fastapi import FastAPI, Query
from fastapi.middleware.cors import CORSMiddleware
# from gas_prediction import get_prediction_results
from pjh import get_local_result
from functionSett import get_total_supply_by_region_2025
from shj import plot_supply_prediction_timeline_A,load_and_preprocess_data
app = FastAPI()

from fastapi.responses import JSONResponse

# CORS 설정 - Spring 서버(8080)와 FastAPI 서버 간 통신
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:8080"],  # Spring 서버 주소
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE"],
    allow_headers=["*"],
)

# @app.get("/api/gas/prediction")
# async def get_gas_prediction():
#     try:
#         results = get_prediction_results()
#         return results
#     except Exception as e:
#         return {"error": str(e)}
    
@app.get("/api/gas/prediction")
async def get_local(city: str = Query(None)):
    try:
        results = get_local_result(city)
        return results
    except Exception as e:
        return {"error": str(e)}
    
@app.get("/api/gas/local")
async def get_local(city: str = Query(None), model: str = Query(None), period: int = Query(3)):
    try:
        results = get_local_result(city, model, period)
        return results
    except Exception as e:
        return {"error": str(e)}
    

@app.get("/api/gas/supply/2025")
async def get_supply_by_region_2025():
    try:
        result = get_total_supply_by_region_2025()
        return result
    except Exception as e:
        return {"error": str(e)}
    
@app.get("/api-supply-prediction")
async def get_supply_prediction():
    try:
        df = load_and_preprocess_data()
        results = plot_supply_prediction_timeline_A(df, 'xgboost', start_date='2024-01-01', end_date='2025-07-01')
        return JSONResponse(content=results)
    except Exception as e:
        return {"error": str(e)}