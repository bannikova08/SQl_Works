/*������� ���������, ��� ������ ������� ����� ����� �������� ��������� ������ ���������� (������������ ������� EMPLOYEES). 
����� ���������� (EMPLOYEE_ID) � ����� ��������� (JOB_ID) �������� � ����������.
����� ��������� ���������� �� ���������� ��� ��������� � ���� ������.*/

accept vstring prompt '������� ����� ����������: ';
accept vstring2 prompt '������� ����� ���������: ';

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
DBMS_OUTPUT.PUT_LINE ('����� ���������� ���������:'||' '||pos);

UPDATE employees
SET job_id=newpos 
WHERE employee_id=empno;

DBMS_OUTPUT.PUT_LINE ('����� ���������:'||' '||newpos);
END;
