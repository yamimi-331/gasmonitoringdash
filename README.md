# 가스 공급량 수요예측 모니터링 대시보드

이 프로젝트는 가스 공급량 공공 데이터를 기반으로 **XGBoost, LSTM, Prophet** 모델을 활용해 수요를 예측하고,
Spring MVC + FastAPI 구조로 예측 결과를 시각화하고 관리할 수 있는 **가스 수요 예측 모니터링 시스템**입니다.

## 프로젝트 구조

```
GasMonitoringDashboard/
├── fastapi-ml/            # 예측 모델 및 API 서버 (FastAPI)
│   ├── data/              # 원본 및 전처리 데이터 저장소
│   ├── models/            # 학습된 모델 파일 (XGBoost, LSTM 등)
│   ├── prediction/        # 예측 로직
│   ├── preprocessing/     # 데이터 전처리
│   ├── training/          # 모델 학습 스크립트
│   ├── visualization/     # 시각화 및 결과 확인용
│   ├── main.py            # FastAPI 실행 진입점
│   ├── coldDaySupply.py   # 한파일 시나리오 예측
│   ├── population.py      # 인구 기반 수요 영향
│   ├── yearsupply.py      # 연간 공급량 예측
│   └── requirements.txt   # Python 의존성 명세
│
├── mysql-query/           # MySQL 테이블 및 더미 데이터 생성 코드
│   ├── table_create.sql
│   ├── t_local_insert.sql
│   ├── t_public_insert.sql
│   ├── t_usage_insert.sql
│   ├── t_user_insert.sql
│   └── dummy_data_insert.sql
│
├── spring-backend/        # Spring MVC 백엔드 (Java)
│   └── GasDashboard/
│       ├── src/main/java/com/eco/
│       │   ├── controller/    # web 컨트롤러
│       │   ├── domain/        # VO/DTO 클래스
│       │   ├── exception/     # 예외 처리
│       │   ├── mapper/        # MyBatis 매퍼 인터페이스
│       │   └── service/       # 비즈니스 로직
│       ├── resources/
│       │   ├── com/eco/mapper/       # MyBatis XML
│       │   ├── log4j.xml
│       │   └── log4jdbc.log4j2.properties
│       ├── webapp/                   # JSP 및 정적 자원
│       └── .gitignore             # Git 이그노어 (spring 내부 추가용: sts)  
├── .gitignore              # Git 이그노어(전체 프로젝트 용: vscode)
└── README.md               # 프로젝트 설명 파일
```

---

## 기술 요소

| 구성 요소  | 기술                                       |
| ------ | ---------------------------------------- |
| 프론트엔드  | JSP, HTML, JS, CSS                 |
| 백엔드    | Java Spring MVC, MyBatis                 |
| 데이터베이스 | MySQL                                    |
| 예측 모델  | Python (FastAPI), XGBoost, LSTM, Prophet |
| 서버통신   | RESTful API (Spring ↔ FastAPI)           |
| 실행 서버  | Uvicorn (FastAPI)                        |

---

## 기능 요약

### 예측 기능 (FastAPI)

* 모델 기본 가스 수요 예측

  * `main.py`에서 다른 함수 호출
  * JSON 형태로 결과 발환

* 모델 구조

  * XGBoost: 가능성 기본 예측
  * LSTM: 시계열 기반 고정도 예측
  * Prophet: 계절성/추상 고도 담수

### 관리 및 모니터링 (Spring MVC)

* 지역/사용자 기본 가스 사용량 관리
* 예측 결과 차트\uub85c 시각화
* 개인/관리자 유형 구분 및 승인 요청 규범

### 데이터베이스 (MySQL)

* 지역, 공공조, 가계조, 사용자 데이터
* 초기 테이블/더미 데이터 제공

---

## 실행 방법

### 1. MySQL 초기화

```bash
mysql -u [USER] -p [DB명] < mysql-query/table_create.sql
mysql -u [USER] -p [DB명] < mysql-query/dummy_data_insert.sql
```

### 2. FastAPI 서버 실행

```bash
cd fastapi-ml
pip install -r requirements.txt
uvicorn main:app --reload
```

### 3. Spring 서버 실행

* `spring-backend/GasDashboard` 를 IDE(STS/IntelliJ) 등으로 import
* Tomcat 또는 Spring Boot Devtools 실행

---

## 기타

* 모델 학습: `fastapi-ml/training/`에서 진행
* 시각화 코드: `visualization/`에 두어 있음
* 지역명 → 카드 변환: 프론트에서 자동 처리

---

## 회고 안

* 현대 프로토 프리공간 이구 (React, Vue) 규포
* Kafka 기능 실시간 데이터 포스트
* Docker 기본 통합 배포 환경 구성

---

## 문의

게등자: 신혁주 (Shin Hyukju)
GitHub: [https://github.com/tmxose](https://github.com/tmxose)
