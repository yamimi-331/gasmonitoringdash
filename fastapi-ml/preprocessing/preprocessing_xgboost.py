import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder

def preprocess_xgboost(path):
    """
    XGBoost 데이터 전처리
    """
    # 데이터 가져오기
    df = pd.read_excel(path)
    # 결측치 처리
    df.fillna(0, inplace=True)
    # 지역명 인코딩
    le = LabelEncoder()
    df['Local'] = le.fit_transform(df['Local'])
    # 날짜 정렬
    df['Date'] = pd.to_datetime(df['Date'])
    df = df.sort_values('Date')
    # 날짜를 숫자형으로 변경
    df['date_ordinal'] = df['Date'].map(pd.Timestamp.toordinal)
    # X, Y설정
    X_xgb = df[['date_ordinal', 'Local_encoded', 'Temperature', 'Humidity', 'Population']]
    Y_xgb = df['GasSupply']
    
    return df, X_xgb, Y_xgb, le