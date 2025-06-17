import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_squared_error, r2_score
import xgboost as xgb
from sklearn.preprocessing import LabelEncoder
import sys
import os
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from training.training_xgboost import training_xgboost
import warnings
warnings.filterwarnings('ignore')

def prediction_xgboost(df):
    """
    XGBoost 데이터 예측
    """
    results = training_xgboost()

    #날짜 문자열 정렬하기
    df = df.copy()
    df['YearMonth'] = df['Date'].dt.to_period('M').astype(str)
    # XGBoost 모델 가져오기
    xgb_model = results['model']