from fastapi import FastAPI
from fastapi.responses import JSONResponse

import pandas as pd

import numpy as np

import matplotlib.pyplot as plt

import seaborn as sns

from sklearn.model_selection import train_test_split
from sklearn.linear_model import LinearRegression
from sklearn.neighbors import KNeighborsRegressor
from sklearn.metrics import mean_squared_error, r2_score 

import io

import base64

app = FastAPI()

@app.get("/ml/result")
def ml_result():
    df = pd.read_excel("귤품질정보.xlsx")
    df["Year"] = df["Date"].dt.year
    df["Month"] = df["Date"].dt.month
    df["Day"] = df["Date"].dt.day

    x = df[["Sour","Flesh","Month","Day"]]
    y = df["Sweet"]

    x_train, x_test, y_train, y_test = train_test_split(x,y,train_size=0.8,random_state=0) 

    ln_model = LinearRegression()
    ln_model.fit(x_train,y_train)
    prd1 = ln_model.predict(x_test)

    mse1 = mean_squared_error(y_test,prd1)
    rmse1 = np.sqrt(mse1)
    r2_1 = r2_score(y_test, prd1)

    kn_model = KNeighborsRegressor()
    kn_model.fit(x_train, y_train)
    prd2 = kn_model.predict(x_test)

    mse2 = mean_squared_error(y_test,prd2)
    rmse2 = np.sqrt(mse2)
    r2_2 = r2_score(y_test, prd2)

    plt.figure(figsize=(6, 4))
    sns.regplot(x="Sour",y="Sweet", data=df)
    plt.title("산미 VS 당도")
    buf = io.BytesIO()
    plt.savefig(buf, format="png")
    plt.close()
    buf.seek(0)
    img_base64 = base64.b64encode(buf.read()).decode("utf-8")

    return JSONResponse(content={
        "linear": {"mse":mse1, "rmse":rmse1, "r2":r2_1},
        "knn": { "mse":mse2, "rmse":rmse2, "r2":r2_2},
        "chart_base64": img_base64
    })