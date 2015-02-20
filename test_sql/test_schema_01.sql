
conn / as sysdba

PROMPT 'Creating Tablespaces'

-- Create tablespaces
CREATE TABLESPACE ts_emp_system DATAFILE 'C:\ORACLEXE\APP\ORACLE\ORADATA\XE\emp_system_01.dbf' SIZE 200M AUTOEXTEND ON;
PROMPT '.... Tablespace creation completed.'


DROP USER emp_user CASCADE;

-- Creating users
PROMPT 'Creating user'
CREATE USER emp_user IDENTIFIED BY password DEFAULT TABLESPACE ts_emp_system QUOTA UNLIMITED ON ts_emp_system;
GRANT CREATE SESSION TO emp_user;
GRANT RESOURCE TO emp_user;
PROMPT '.... User created with required privileges'

-- Connect as the schema user
PROMPT 'Connecting as Employee user'
conn emp_user/password

-- Cleanup object before creating 
/* Uncomment when necessary */
-- DROP TABLE department CASCADE CONSTRAINTS;
-- DROP TABLE employee CASCADE CONSTRAINTS;
-- DROP SEQUENCE seq_emp_id;


-- Create Employee table
CREATE TABLE employee (
id			NUMBER(10),
name		VARCHAR(50) NOT NULL,
pan_number	VARCHAR(10) NOT NULL UNIQUE,
gender		CHAR(1),
cell_phone	VARCHAR(15),
CONSTRAINT emp_pk PRIMARY KEY(id),
CONSTRAINT emp_gender_chk CHECK(gender IN ('M', 'F') )
);

-- Create Department table - an example to create a table in a desired tablespace
CREATE TABLE department (
id			NUMBER(10),
dept_name	VARCHAR(50),
CONSTRAINT dept_pk PRIMARY KEY(id)
) TABLESPACE ts_emp_system; 

-- Create constraints
ALTER TABLE department ADD CONSTRAINT dept_name_u UNIQUE(dept_name);

-- Sequence
CREATE SEQUENCE seq_emp_id START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;


-- Let us add SALARY column to employee table
ALTER TABLE employee ADD (salary number(10) );
ALTER TABLE employee ADD (dept_id NUMBER(10) );

-- Insert sample data
INSERT INTO department VALUES (2001,'PRODUCTION');
INSERT INTO department VALUES (2002,'SALES');
INSERT INTO department VALUES (2003,'MARKETING');
INSERT INTO department VALUES (2004,'SUPPORT');

COMMIT;

INSERT INTO employee VALUES (seq_emp_id.nextval,'AAAA','ABCXX1000Z','M',9999900001,20000,2002);
INSERT INTO employee VALUES (seq_emp_id.nextval,'AAAB','ABCXX1001Z','M',9999900002,18500,2001);
INSERT INTO employee VALUES (seq_emp_id.nextval,'AAAC','ABCXX1002Z','F',9999900003,63000,2001);
INSERT INTO employee VALUES (seq_emp_id.nextval,'AAAD','ABCXX1003Z','M',9999900004,7500,2003);
INSERT INTO employee VALUES (seq_emp_id.nextval,'AAAE','ABCXX1004Z','F',9999900005,30000,2002);
INSERT INTO employee VALUES (seq_emp_id.nextval,'AAAF','ABCXX1005Z','F',9999900006,24000,2001);
INSERT INTO employee VALUES (seq_emp_id.nextval,'AAAF','ABCXX1006Z','F',9999900007,52000,2002);
INSERT INTO employee VALUES (seq_emp_id.nextval,'AAAG','ABCXX1007Z','M',9999900008,14000,2003);
INSERT INTO employee VALUES (seq_emp_id.nextval,'AAAH','ABCXX1008Z','M',9999900009,18500,2003);
INSERT INTO employee VALUES (seq_emp_id.nextval,'AAAI','ABCXX1009Z','M',9999900010,18500,2001);

COMMIT;

select id, rownum from employee;
select id, rownum from employee order by id;
select rownum, id from employee order by id desc;

-------------count functions---Questions----->>>>>>

-- count the num of males those are males and whose salary isgreater than 20000
select count(id) "count" from employee where salary>20000 and gender = 'M';

-- count the num of employees whose salary more than 60000
select count(id) "count" from employee where salary>60000;

-- pseudo column describe --->>> 
-- list only one record from the table--->>
select * from employee where rownum<2;
select id, rownum from employee where gender = 'F';

-- get all employees emp_name, emp_id, dept_id from employee table
select id,name,dept_id from employee;

-- joining two tables to get data from two tables--
SELECT E.ID, E.NAME, D.DEPT_NAME FROM EMPLOYEE E, DEPARTMENT D WHERE E.DEPT_ID = D.ID;

------------------------------ OR ------------------------------join or natural join

SELECT E.ID, E.NAME, D.DEPT_NAME FROM EMPLOYEE E JOIN DEPARTMENT D ON E.DEPT_ID = D.ID;


-- if dept_id would have named same in both tables --
SELECT E.ID, E.NAME, D.DEPT_NAME FROM EMPLOYEE E JOIN DEPARTMENT D ON DEPT_ID;
SELECT E.ID, E.NAME, D.DEPT_NAME FROM EMPLOYEE E NATURAL JOIN DEPARTMENT D ON (E.DEPT_ID = D.ID);


-- almost same as the one above
SELECT * FROM EMPLOYEE E JOIN DEPARTMENT D ON E.DEPT_ID = D.ID;


------------------------ cross join as cartesian join gives product of both rows ------------------------
SELECT * FROM EMPLOYEE E, DEPARTMENT D;
SELECT E.ID, E.NAME, D.ID, D.DEPT_NAME FROM EMPLOYEE E, DEPARTMENT D;


-------------- all employees that belong PRODUCTION dept_id --------------
SELECT E.* 
FROM EMPLOYEE E JOIN DEPARTMENT D ON (E.DEPT_ID = D.ID)
WHERE D.DEPT_NAME = 'PRODUCTION';


----------------------------------- TOTAL SALARY DRAWN BY FEMALES IN SALES DEPT. -----------------------------------
SELECT SUM(E.SALARY) 
	FROM EMPLOYEE E JOIN DEPARTMENT D 
	ON (E.DEPT_ID = D.ID) 
	WHERE D.DEPT_NAME = 'SALES' AND E.GENDER = 'F';


---------------------- AVG SALARY OF MALES WORKING IN MARKETING DEPT ----------------------
SELECT AVG(E.SALARY) 
	FROM EMPLOYEE E JOIN DEPARTMENT D 
	ON (E.DEPT_ID = D.ID) 
	WHERE D.DEPT_NAME = 'MARKETING' AND E.GENDER = 'M';


-------------------- GET THE AVG SALARY OF EMPLOYEES WORKING IN BOTH SALES N MARKETING  ----------------
SELECT AVG(E.SALARY) 
	FROM EMPLOYEE E JOIN DEPARTMENT D 
	ON (E.DEPT_ID = D.ID) 
	WHERE D.DEPT_NAME = 'MARKETING' OR D.DEPT_NAME = 'SALES';

---------------------------------- DEPTS WHO DON'T HAVE EMPLOYEES ----------------------------------
