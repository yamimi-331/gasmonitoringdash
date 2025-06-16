from fastapi import FastAPI, Query
from fastapi.middleware.cors import CORSMiddleware
# from gas_prediction import get_prediction_results
from pjh import get_local_result

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