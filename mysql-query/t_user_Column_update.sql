use GasDashboardDB;

-- 1. 기존 admin_yn 컬럼 삭제
ALTER TABLE t_user
DROP COLUMN admin_yn;

-- 2. 새 user_type 컬럼 추가
ALTER TABLE t_user
ADD COLUMN user_type VARCHAR(100) NOT NULL DEFAULT 'common';
select * from t_user;

update t_user set user_type = 'admin' where user_id = 'admin';