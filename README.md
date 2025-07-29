# 가스 공급량 수요 예측 모니터링 대시보드 Gas Monitoring Dashboard

## 💡 프로젝트 개요
**Gas Monitoring Dashboard**는  가스 공급량 공공 데이터를 기반으로 **XGBoost, LSTM, Prophet** 모델을 활용하여 수요를 예측하고, 예측 결과를 시각화 및 관리할 수 있도록  **Spring MVC와 FastAPI를 연동한 모니터링 시스템**입니다. 본 프로젝트는 가스 수요 예측의 정확성을 높이고, 예측 결과를 효율적으로 관리 및 모니터링하는 데 중점을 두었습니다.

## 🛠️ 개발 환경 및 기술 스택

- 개발 기간: 2025년 6월 13일 ~ 2025년 7월 1일
- 개발자: 신혁주(팀장), 박정현, 팀원
- 프레임워크: Spring Framework (Spring MVC), FastAPI
- IDE: STS3 (Spring Tool Suite 3)
- 서버: Apache Tomcat 9 (Spring Backend), Uvicorn (FastAPI)
- 데이터베이스: MySQL
- 아키텍처: MVC (Spring) + RESTful API (Spring ↔ FastAPI) + Machine Learning (FastAPI)
- 예측 모델: Python (XGBoost, LSTM, Prophet)

## 📁 프로젝트 구조

프로젝트는 효율적인 관리와 역할 분담을 위해 다음과 같이 모듈화하여 구성되었습니다.

```
📁GasMonitoringDashboard/
├── 📁fastapi-ml/            # 예측 모델 및 API 서버 (FastAPI)
│   ├── 📁data/              # 원본 및 전처리 데이터 저장소
│   ├── 📁models/            # 학습된 모델 파일 (XGBoost, LSTM 등)
│   ├── 📁prediction/        # 예측 로직
│   ├── 📁preprocessing/     # 데이터 전처리
│   ├── 📁training/          # 모델 학습 스크립트
│   ├── 📁visualization/     # 시각화 및 결과 확인용
│   ├── 🐍main.py            # FastAPI 실행 진입점
│   ├── 🐍coldDaySupply.py   # 한파일 시나리오 예측
│   ├── 🐍population.py      # 인구 기반 수요 영향
│   ├── 🐍yearsupply.py      # 연간 공급량 예측
│   └── 📑requirements.txt   # Python 의존성 명세
├── 📁mysql-query/           # MySQL 테이블 및 더미 데이터 생성 코드
│   ├── 📑table_create.sql
│   ├── 📑t_local_insert.sql
│   ├── 📑t_public_insert.sql
│   ├── 📑t_usage_insert.sql
│   ├── 📑t_user_insert.sql
│   └── 📑dummy_data_insert.sql
├── 📁spring-backend/        # Spring MVC 백엔드 (Java)
│   └── 📁GasDashboard/
│       ├── 📁src/main/java/com/eco/
│       │   ├── 📁controller/    # web 컨트롤러
│       │   ├── 📁domain/        # VO/DTO 클래스
│       │   ├── 📁exception/     # 예외 처리
│       │   ├── 📁mapper/        # MyBatis 매퍼 인터페이스
│       │   └── 📁service/       # 비즈니스 로직
│       ├── 📁resources/
│       │   ├── 📁com/eco/mapper/       # MyBatis XML
│       │   ├── 📑log4j.xml
│       │   └── 📑log4jdbc.log4j2.properties
│       ├── 📁webapp/                   # JSP 및 정적 자원
│       └── 📑.gitignore             # Git 이그노어 (spring 내부 추가용: sts)  
├── 📑.gitignore              # Git 이그노어(전체 프로젝트 용: vscode)
└── 📑README.md               # 프로젝트 설명 파일
```

## ✨ 주요 기능

**수요 예측 기능 (FastAPI)**

* **가스 수요 예측 모델**:

  * `main.py`를 통해 XGBoost, LSTM, Prophet 모델을 활용한 가스 수요 예측을 수행합니다.
  * XGBoost: 주요 변수 기반의 기본적인 예측을 수행합니다.
  * LSTM: 시계열 데이터의 장기적인 패턴을 학습하여 높은 정확도의 예측을 제공합니다.
  * Prophet: 계절성 및 추세 요소를 자동으로 감지하여 복잡한 시계열 예측에 강점을 보입니다.
    
* **특정 시나리오 예측**:

  * `coldDaySupply.py`: 한파 시나리오에 따른 가스 공급량 예측을 지원합니다.
  * `population.py`: 인구 변화가 가스 수요에 미치는 영향을 분석합니다.
  * `yearsupply.py`: 연간 가스 공급량을 예측합니다.
    
* **JSON 결과 반환**:
 
 * 예측 결과는 RESTful API를 통해 JSON 형태로 반환되어 Spring 백엔드와 연동됩니다.

**관리 및 모니터링 (Spring MVC)**

* 가스 사용량 관리: 로그인 기능을 통해 사용자별 개인 사용량 조회 및 지역별 평균 데이터와 비교하여 가스 사용량 절약 플랜을 세울수도 있습니다.
* 예측 결과 시각화: FastAPI로부터 받은 예측 결과를 차트 형태로 시각화하여 직관적인 모니터링을 가능하게 합니다.
* 권한 관리: 개인 사용자 및 관리자 유형을 구분하며, 특정 기능에 대한 승인 요청 규범을 적용합니다.
  
**데이터베이스 (MySQL)**

* 지역, 공공기관, 사용자 등 가스 수요 예측 및 관리에 필요한 데이터를 저장합니다.
* 초기 테이블 생성 스크립트와 더미 데이터를 제공하여 즉시 환경 구축이 가능합니다.

---

## 🚀 프로젝트 실행 방법

**1.프로젝트 클론:**

```bash
git clone https://github.com/tmxose/GasMonitoringDashboard.git
```

**2. MySQL 초기화:**

 - MySQL 데이터베이스를 생성합니다.
 - 제공된 SQL 파일을 사용하여 필요한 테이블을 생성하고 더미 데이터를 삽입합니다.

```bash
mysql -u [USER] -p [DB_NAME] < mysql-query/table_create.sql
mysql -u [USER] -p [DB_NAME] < mysql-query/dummy_data_insert.sql

```

**2. FastAPI 서버 실행**

 - fastapi-ml 디렉토리로 이동합니다.
 - 필요한 Python 의존성을 설치합니다.
 - Uvicorn을 사용하여 FastAPI 애플리케이션을 실행합니다.

```bash
cd fastapi-ml
pip install -r requirements.txt
uvicorn main:app --reload
```

**3. Spring 서버 실행**

 - spring-backend/GasDashboard 프로젝트를 IDE (STS/IntelliJ)로 임포트합니다.
 - src/main/webapp/WEB-INF/spring/root-context.xml 파일에 데이터베이스 연결 정보를 설정합니다.
 - Maven 의존성 설치: 프로젝트 우클릭 -> Maven -> Update Project... 를 통해 필요한 의존성을 다운로드합니다.
 - Apache Tomcat 9 서버를 IDE에 연동하고, 프로젝트를 서버에 추가합니다.
 - Tomcat 서버를 시작하여 웹 애플리케이션을 실행합니다.

## **🚀 프로젝트 시연 영상**


https://github.com/user-attachments/assets/0f033999-f4a4-4dd8-b7b1-6de7bfeb55c6



