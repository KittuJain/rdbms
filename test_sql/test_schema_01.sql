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
ALTER TABLE employee ADD (salary number(10));
ALTER TABLE employee ADD (dept_id NUMBER(10));

-- Insert sample data
INSERT INTO department VALUES (2001,'PRODUCTION');
INSERT INTO department VALUES (2002,'SALES');
INSERT INTO department VALUES (2003,'MARKETING');
INSERT INTO department VALUES (2004,'SUPPORT');

COMMIT;

INSERT INTO employee VALUES (seq_emp_id.nextval,'AAAA','ABCXX1000Z','M',9999900001,20000,2002);
INSERT INTO employee VALUES (seq_emp_id.nextval,'AAAB','ABCXX1001Z','M',9999900002,18500,2001);
INSERT INTO employee VALUES (seq_emp_id.nextval,'AAAC','ABCXX1002Z','F',9999900003,63000,2001);
INSERT INTO employee VALUES (seq_emp_id.nextval,'AAAD','ABCXX1003Z','M',9999900004,7500, 2003);
INSERT INTO employee VALUES (seq_emp_id.nextval,'AAAE','ABCXX1004Z','F',9999900005,30000,2002);
INSERT INTO employee VALUES (seq_emp_id.nextval,'AAAF','ABCXX1005Z','F',9999900006,24000,2001);
INSERT INTO employee VALUES (seq_emp_id.nextval,'AAAF','ABCXX1006Z','F',9999900007,52000,2002);
INSERT INTO employee VALUES (seq_emp_id.nextval,'AAAG','ABCXX1007Z','M',9999900008,14000,2003);
INSERT INTO employee VALUES (seq_emp_id.nextval,'AAAH','ABCXX1008Z','M',9999900009,18500,2003);
INSERT INTO employee VALUES (seq_emp_id.nextval,'AAAI','ABCXX1009Z','M',9999900010,18500,2001);
INSERT INTO employee(id,name,pan_number,gender,cell_phone,salary) 
VALUES (seq_emp_id.nextval,'AAAJ','ABCXX1010Z','F',9999900011,20500);

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


------------------------ cross join as cartesian join gives product of both rows 40 rows------------------------

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


-------------all employees name and dept_name----------------------------------------
SELECT E.NAME, D.DEPT_NAME 
	FROM EMPLOYEE E JOIN DEPARTMENT D 
	ON (E.DEPT_ID = D.ID);

------------inserting transport in dept
INSERT INTO department VALUES (2005,'TRANSPORT');

-------------------------left outer join-----------------11 rows
SELECT * 
	FROM EMPLOYEE E LEFT OUTER JOIN DEPARTMENT D 
	ON (E.DEPT_ID = D.ID);

-------------------------- right outer join-----------12 rows
SELECT * 
	FROM EMPLOYEE E RIGHT OUTER JOIN DEPARTMENT D 
	ON (E.DEPT_ID = D.ID);

----------------------- right outer join 11 rows -------------
SELECT * 
	FROM DEPARTMENT D RIGHT OUTER JOIN EMPLOYEE E  
	ON (E.DEPT_ID = D.ID);

----------all employee names and dept_name----------
SELECT * 
	FROM EMPLOYEE E FULL OUTER JOIN DEPARTMENT D  
	ON (E.DEPT_ID = D.ID);

---all employees who work in production and sales

SELECT E.NAME 
	FROM EMPLOYEE E JOIN DEPARTMENT D 
	ON (E.DEPT_ID = D.ID) 
	WHERE D.DEPT_NAME = 'PRODUCTION' OR D.DEPT_NAME = 'SALES';

SELECT E.NAME 
	FROM EMPLOYEE E JOIN DEPARTMENT D 
	ON (E.DEPT_ID = D.ID) 
	WHERE D.DEPT_NAME IN ('PRODUCTION','SALES');

--employeees who don't work in production and sales
SELECT E.NAME 
	FROM EMPLOYEE E JOIN DEPARTMENT D 
	ON (E.DEPT_ID = D.ID) 
	WHERE D.DEPT_NAME NOT IN ('PRODUCTION','SALES');

----select all employees with full details of production sector
SELECT E.* FROM EMPLOYEE E JOIN DEPARTMENT D ON (E.DEPT_ID = D.ID) 
	WHERE D.DEPT_NAME IN ('PRODUCTION');

------------ view in db table for other users it is basically a stored query
-- 2 types of views are ->>> view and a materialised view
----- grant permission to emp_user to create view
CONNECT / AS SYSDBA;
GRANT CREATE VIEW TO emp_user;

connect emp_user/password;

CREATE VIEW PRODUCTION_EMPLOYEES AS 
	SELECT E.* FROM EMPLOYEE E JOIN DEPARTMENT D ON (E.DEPT_ID = D.ID) 
	WHERE D.DEPT_NAME IN ('PRODUCTION');

SELECT * FROM PRODUCTION_EMPLOYEES;
------- CREATE NEW USER AND GRANT IT PRIVILEGE TO ACCESS PRODUCTION_EMPLOYEES VIEW

CONNECT / AS SYSDBA;
CREATE USER reporter IDENTIFIED BY reporter DEFAULT TABLESPACE ts_emp_system QUOTA UNLIMITED ON ts_emp_system;
CONNECT emp_user/password;
GRANT SELECT ON PRODUCTION_EMPLOYEES TO reporter;
COMMIT;
CONNECT / AS SYSDBA;
GRANT CREATE SESSION TO reporter;
GRANT RESOURCE TO reporter;
COMMIT;
CONNECT reporter/reporter;
SELECT * FROM emp_user.PRODUCTION_EMPLOYEES;

---------create synonymns-------
--------- public synonymn private synonymn ------------------
-- CREATE SYNONYM prod_emp FOR emp.PRODUCTION_EMPLOYEES;
-- SELECT * FROM prod_emp;

----create or replace view-----drops and creates a new view it overrides existing one -- recrerated definition
select * from all_views where rownum<2;

-----union in sets------
-- two sets (a b) and (a b c) have a union as (a b c) taken common once
----- intersects in sets------
-- two sets (a b) and (a b c) have a intersect as (a b) only common between both
--- minus in sets--------
-- two sets (a b) and (a b c) have a minus as (c)
-- get emp_id and emp_name whose dept_id is 2001 and 2002
CONNECT emp_user/password;
SELECT ID, NAME FROM EMPLOYEE WHERE DEPT_ID = 2001 OR DEPT_ID = 2002;
SELECT ID, NAME FROM EMPLOYEE WHERE DEPT_ID = 2002;
SELECT ID, NAME FROM EMPLOYEE WHERE DEPT_ID = 2001;

------------------------------------------- SET OPERATORS --------------------
-- UNION IS APPLICABLE ONLY WHEN SELECTION IS COMMON --
SELECT ID, NAME FROM EMPLOYEE WHERE DEPT_ID = 2001 UNION SELECT ID, NAME FROM EMPLOYEE WHERE DEPT_ID = 2002;
SELECT ID, NAME FROM EMPLOYEE WHERE DEPT_ID IN(2001) UNION SELECT ID, NAME FROM EMPLOYEE WHERE DEPT_ID IN(2002);

-- SELECT ID, NAME FROM EMPLOYEE WHERE DEPT_ID IN(2001) UNION SELECT ID, NAME FROM EMPLOYEE WHERE DEPT_ID IN(2002);

CREATE VIEW SALES_EMPLOYEES AS 
	SELECT E.* FROM EMPLOYEE E JOIN DEPARTMENT D ON (E.DEPT_ID = D.ID) 
	WHERE D.DEPT_NAME IN ('SALES');

COMMIT;

--- SIX ROWS------
SELECT NAME FROM PRODUCTION_EMPLOYEES UNION SELECT NAME FROM SALES_EMPLOYEES;
--- SEVEN ROWS----- union all ------------
SELECT ID FROM PRODUCTION_EMPLOYEES UNION SELECT ID FROM SALES_EMPLOYEES;
SELECT NAME FROM PRODUCTION_EMPLOYEES UNION ALL SELECT NAME FROM SALES_EMPLOYEES;

SELECT NAME FROM PRODUCTION_EMPLOYEES INTERSECT SELECT NAME FROM SALES_EMPLOYEES;
SELECT ID,NAME FROM PRODUCTION_EMPLOYEES UNION SELECT ID,NAME FROM SALES_EMPLOYEES;

---------------- self join 
---------------- hierarchical data model ------------------
ALTER TABLE employee
ADD FOREIGN KEY (manager_id) 
REFERENCES employee(id);
COMMIT;

--------- CREATE BACKUP FOR AN EXISTING TABLE ---------
CREATE TABLE EMP_BACKUP AS SELECT * FROM EMPLOYEE;
COMMIT;
SELECT * FROM EMP_BACKUP;

-------------------- GET ALL CONSTRAINTS -----------------------------
SELECT * FROM USER_CONSTRAINTS;
SELECT CONSTRAINT_NAME, CONSTRAINT_TYPE FROM USER_CONSTRAINTS WHERE TABLE_NAME = 'EMPLOYEE';

ALTER TABLE EMPLOYEE DROP COLUMN manager_id;
-- Add a column for mgr_id in employee table
ALTER TABLE employee ADD ( mgr_id NUMBER(10));

-- Add a foreign 
ALTER TABLE employee ADD CONSTRAINT mgr_id_emp FOREIGN KEY (mgr_id) REFERENCES employee(id);

-- Define managers
UPDATE employee SET mgr_id=11  WHERE id=2;
UPDATE employee SET mgr_id=2  WHERE id=3;
UPDATE employee SET mgr_id=2  WHERE id=6;
UPDATE employee SET mgr_id=2  WHERE id=10;
UPDATE employee SET mgr_id=11  WHERE id=1;
UPDATE employee SET mgr_id=1  WHERE id=5;
UPDATE employee SET mgr_id=1  WHERE id=7;
UPDATE employee SET mgr_id=11  WHERE id=4;
UPDATE employee SET mgr_id=4  WHERE id=8;
UPDATE employee SET mgr_id=4  WHERE id=9;

COMMIT;
SELECT * FROM EMPLOYEE WHERE ID = 11;
DELETE FROM EMPLOYEE WHERE ID = 11;

CREATE TABLE MANAGERS AS SELECT ID,NAME FROM EMPLOYEE;
COMMIT;

-- 11 ROWS
SELECT E.ID, E.NAME, M.NAME FROM EMPLOYEE E JOIN MANAGERS M ON E.ID = M.ID;

-- 10 ROWS --- BOTH STATEMENTS ARE SIMILAR ---
SELECT E.ID, E.NAME, M.NAME FROM EMPLOYEE E JOIN MANAGERS M ON E.MGR_ID = M.ID;
SELECT E.ID, E.NAME, M.NAME FROM EMPLOYEE E JOIN EMPLOYEE M ON E.MGR_ID = M.ID;


------- JOINING MULTIPLE TABLES
SELECT E.ID, E.NAME, M.NAME, D.DEPT_NAME 
FROM EMPLOYEE E JOIN DEPARTMENT D 
ON E.DEPT_ID = D.ID
JOIN EMPLOYEE M ON M.ID=E.MGR_ID;

SELECT E.ID, E.NAME, M.NAME, D.DEPT_NAME 
FROM EMPLOYEE E, DEPARTMENT D, EMPLOYEE M WHERE E.DEPT_ID = D.ID AND M.ID=E.MGR_ID;

SELECT E.ID, E.NAME, M.NAME, D.DEPT_NAME 
FROM EMPLOYEE E LEFT OUTER JOIN DEPARTMENT D 
ON E.DEPT_ID = D.ID
LEFT OUTER JOIN EMPLOYEE M ON M.ID=E.MGR_ID;