/*Создать программу, при помощи которой можно будет обновить должность любого сотрудника (используется таблица EMPLOYEES). 
Номер сотрудника (EMPLOYEE_ID) и новая должность (JOB_ID) вводятся с клавиатуры.
Новая должность выбирается из должностей уже имеющихся в базе данных.*/

accept vstring prompt 'Укажите номер сотрудника: ';
accept vstring2 prompt 'Укажите новую должность: ';

DECLARE
empno NUMBER(10):='&vstring';
newpos VARCHAR2(15):='&vstring2';
fname VARCHAR2(15);
lname VARCHAR2(15);
pos VARCHAR2(15);
BEGIN

SELECT first_name, last_name, job_id
INTO fname,lname,pos
FROM employees
WHERE employee_id=empno;
DBMS_OUTPUT.PUT_LINE (fname||' '||lname);
DBMS_OUTPUT.PUT_LINE ('Ранее занимаемая должность:'||' '||pos);

UPDATE employees
SET job_id=newpos 
WHERE employee_id=empno;

DBMS_OUTPUT.PUT_LINE ('Новая должность:'||' '||newpos);
END;
