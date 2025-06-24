-- 데이터 베이스 생성
CREATE DATABASE IF NOT EXISTS GasDashboardDB;
-- DB 선택
use GasDashboardDB;

-- T_LOCAL
CREATE TABLE T_LOCAL (
    local_cd  CHAR(3)     NOT NULL primary key,              -- 지역 코드 (예: L01)
    local_nm  VARCHAR(20) NOT NULL,              -- 지역 이름 (예: 서울)
    use_yn    CHAR(1)     NOT NULL DEFAULT 'Y'  -- 사용 여부 (기본값 Y)
);

-- T_USER 생성
CREATE TABLE T_USER (
    user_cd    CHAR(11)     NOT NULL primary key,              -- YYYY+RRR+SSSS 형태의 사용자 코드
    user_id    VARCHAR(50)  NOT NULL UNIQUE,       -- 사용자 ID (고유)
    user_pw    VARCHAR(100),              -- 비밀번호
    user_nm    VARCHAR(15),              -- 사용자 이름
    local_cd   CHAR(3)  NOT NULL,              -- 지역 코드 (FK)
    user_addr  VARCHAR(100) NOT NULL,              -- 상세 주소
    user_type   VARCHAR(100)      NOT NULL DEFAULT 'common',  -- 회원 등급 (기본값 common)
    use_yn     CHAR(1)      NOT NULL DEFAULT 'Y',  -- 사용 여부 (기본값 Y)
    FOREIGN KEY (local_cd) REFERENCES T_LOCAL(local_cd)
);

-- T_USAGE 생성
CREATE TABLE T_USAGE (
    usage_cd      INT         NOT NULL AUTO_INCREMENT primary key, -- 가스 사용량 고유 코드 (자동 증가)
    user_cd       CHAR(11)    NOT NULL,                -- 사용자 코드 (FK: T_USER)
    local_cd      CHAR(3)     NOT NULL,                -- 지역 코드 (FK: T_LOCAL)
    usage_dt      CHAR(7)     NOT NULL,                -- 사용 년월 ("YYYY-MM")
    usage_amount  INT         NOT NULL,                -- 사용량 (단위: m³)
    use_yn        CHAR(1)     NOT NULL DEFAULT 'Y',    -- 사용 여부 (기본값 Y)
    FOREIGN KEY (user_cd) REFERENCES T_USER(user_cd),
    FOREIGN KEY (local_cd) REFERENCES T_LOCAL(local_cd)
);

-- T_PUBLIC 생성
CREATE TABLE T_PUBLIC (
    public_cd      INT         NOT NULL AUTO_INCREMENT primary key, -- 공공 사용량 고유 코드
    local_cd       CHAR(3)     NOT NULL,                -- 지역 코드 (FK: T_LOCAL)
    public_dt      CHAR(7)     NOT NULL,                -- 사용 년월 ("YYYY-MM")
    public_amount  INT         NOT NULL,                -- 평균 사용량 (단위: m³)
    use_yn         CHAR(1)     NOT NULL DEFAULT 'Y',    -- 사용 여부 (기본값 Y)
    FOREIGN KEY (local_cd) REFERENCES T_LOCAL(local_cd)
);
