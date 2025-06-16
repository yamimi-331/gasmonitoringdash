from fastapi import FastAPI, Query
from fastapi.middleware.cors import CORSMiddleware
# from gas_prediction import get_prediction_results
from pjh import get_local_result
from functionSett import get_total_supply_by_region_2025

app = FastAPI()

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
    

@app.get("/api/gas/supply/2025")
async def get_supply_by_region_2025():
    try:
        result = get_total_supply_by_region_2025()
        return result
    except Exception as e:
        return {"error": str(e)}