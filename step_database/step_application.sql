conn / as sysdba
-- @D:/rdbms/step_database/step_application.sql;
-- DROP USER step_admin CASCADE;
-- DROP TABLESPACE ts_step_system INCLUDING CONTENTS AND DATAFILES;
-- Create tablespaces
PROMPT 'Creating Tablespace for step system'
CREATE TABLESPACE ts_step_system DATAFILE 'C:\ORACLEXE\APP\ORACLE\ORADATA\XE\step_system.dbf' SIZE 200M AUTOEXTEND ON;
PROMPT '.... Tablespace creation completed.'


-- Creating users
PROMPT 'Creating user'
CREATE USER step_admin IDENTIFIED BY password DEFAULT TABLESPACE ts_step_system QUOTA UNLIMITED ON ts_step_system;
GRANT CREATE SESSION TO step_admin;
GRANT RESOURCE TO step_admin;
PROMPT 'USER CREATED'

--LOGGING IN AS STEP USER
CONN step_admin/password;
--Creating Applicant table
PROMPT 'Creating Applicant table'
CREATE TABLE APPLICANT (
	APPLICANTION_NUM	NUMBER(10) PRIMARY KEY,
	NAME				VARCHAR(50) NOT NULL,
	GENDER				CHAR(1),
	D_O_B				DATE,
	ID_PROOF			VARCHAR(15),
	BOARD_OF_STUDY		NUMBER(5),
	REGISTER_NUMBER		NUMBER(10),
	YEAR_OF_PASSING		NUMBER(4),
	STATE 				VARCHAR(50),
	PASSWORD			VARCHAR(10)
);


--Creating contact_details table
PROMPT 'Creating contact_details table'
CREATE TABLE CONTACT_DETAILS (
	APPLICANTION_NUM	NUMBER(10) PRIMARY KEY,
	MOBILE_NUMBER		NUMBER(10),
	EMAIL_ID			VARCHAR(40),
	HOUSE_NAME 			VARCHAR(200),
	STREET_NAME 		VARCHAR(200),
	CITY 				VARCHAR(25),
	PIN_CODE 			NUMBER(6)
);

-- COMMIT;