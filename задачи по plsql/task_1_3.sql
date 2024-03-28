/*������ ������� ROUTE �� ���������:
ID NUMBER PRIMARY KEY,
CITY1 VARCHAR2(40),
CITY2 VARCHAR2(40),
DIST NUMBER,
��� ID � ���������� �����, CITY1 � CITY2 � �������� �������, DIST � ���������� ����� ��������.
 �������� ������� � ���������.
������� ���������, ������� �������� �������� ���� ����� ����� �������� � ����������
����������� ��������� � �������� ����� ��� ���� � ���������� ������.
����� ������� � ��������� ���������.
��������� ������ ��������������� ��������� ����������.
������ ������������� ���������� ��� ������� ����� � �������:
�������� ����� ����� � ������� � ���������� ����������� ���������
����� � ������ - ������� ����� �������� - 120
����� - ������ - ������� ����� �������� - 200
����������� ���������� ��������� - 1
������� � ���������� ������ � � ���������� ����������� ���������:
����� � ������ - ������� ����� �������� - 120*/

DROP TABLE ROUTE;
CREATE TABLE ROUTE (
ID NUMBER PRIMARY KEY,
CITY1 VARCHAR2(40),
CITY2 VARCHAR2(40),
DIST NUMBER(10)
);

--���������� �������
INSERT INTO ROUTE (ID, CITY1, CITY2, DIST) VALUES (1, '������', '�����-���������', 634);
INSERT INTO ROUTE (ID, CITY1, CITY2, DIST) VALUES (2, '�����-���������', '������������', 2292);
INSERT INTO ROUTE (ID, CITY1, CITY2, DIST) VALUES (3, '������','������', 809);
INSERT INTO ROUTE (ID, CITY1, CITY2, DIST) VALUES (4, '������', '������������', 717);
INSERT INTO ROUTE (ID, CITY1, CITY2, DIST) VALUES (5, '������������', '�������', 2813);
INSERT INTO ROUTE (ID, CITY1, CITY2, DIST) VALUES (6, '������', '����', 1620);
INSERT INTO ROUTE (ID, CITY1, CITY2, DIST) VALUES (7, '����', '�������', 4798);
INSERT INTO ROUTE (ID, CITY1, CITY2, DIST) VALUES (8, '����', '�����', 1384);
INSERT INTO ROUTE (ID, CITY1, CITY2, DIST) VALUES (9, '������', '���������', 1345);
INSERT INTO ROUTE (ID, CITY1, CITY2, DIST) VALUES (10, '���������', '�����', 165);

COMMIT;

--�������
--������������ ������
/
CREATE OR REPLACE PACKAGE PATH3 IS
PROCEDURE FIND_SHORTEST_PATH(START_CITY ROUTE.CITY1%TYPE, FINISH_CITY ROUTE.CITY2%TYPE);
END PATH3;

--���� ������
/
CREATE OR REPLACE PACKAGE BODY PATH3 IS
--����������:
TYPE way_rec IS RECORD(WSTR VARCHAR2(100), RESDIS NUMBER(10), LASTCITY ROUTE.CITY1%TYPE);
TYPE ways_tab IS TABLE OF way_rec;
--������� � ���������:
FUNCTION CREATE_START_PATH_TAB(START_CITY ROUTE.CITY1%TYPE) RETURN ways_tab;
FUNCTION DIFFERENT_CITY(SAMPLE_CITY ROUTE.CITY1%TYPE, CITY1 ROUTE.CITY1%TYPE, CITY2 ROUTE.CITY1%TYPE) RETURN ROUTE.CITY1%TYPE;
FUNCTION FIND_PATH(START_CITY ROUTE.CITY1%TYPE, FINISH_CITY ROUTE.CITY2%TYPE) RETURN ways_tab;
FUNCTION ISCYCLE(STR IN VARCHAR2, CITY IN ROUTE.CITY1%TYPE) RETURN BOOLEAN;
PROCEDURE MAKE_NEXT_STEP(OLD_TAB IN ways_tab, FINISH_CITY IN ROUTE.CITY2%TYPE, FOUND_ROUTE IN OUT ways_tab);

--������� ������ �� ������ ������� ROUTE ��������� ������� ���� ����� �� ������ START_CITY.
--����: START_CITY - �����, �� �������� ����� ��������� ����.
--�����: ��������� ������� � ������ �� START_CITY
FUNCTION CREATE_START_PATH_TAB(START_CITY ROUTE.CITY1%TYPE)
RETURN ways_tab IS
temp_tab ways_tab := ways_tab();
v_wayRec way_rec;
CURSOR c_ways IS
SELECT CITY1, CITY2, DIST
FROM ROUTE
WHERE CITY1 = START_CITY OR CITY2 = START_CITY;
v_ind NUMBER(10) := 1;
next_city ROUTE.CITY1%TYPE;
BEGIN

FOR rec IN c_ways LOOP
--���������� ��������� �����
next_city := DIFFERENT_CITY(START_CITY, rec.CITY1, rec.CITY2);
--������ ������
v_wayRec.WSTR := START_CITY || ' � ' || next_city;
v_wayRec.RESDIS := rec.DIST;
v_wayRec.LASTCITY := next_city;
--v_wayRec.TRANSFERS := LENGTH(v_wayRec.WSTR) - LENGTH(REPLACE(v_wayRec.WSTR, '-', ''));
--��������� ������
temp_tab.EXTEND;
temp_tab(v_ind) := v_wayRec;
--����������� ������� ������� �������
v_ind := v_ind + 1;
END LOOP;
RETURN temp_tab;
END CREATE_START_PATH_TAB;

--������� ���������� �����, �������� �� ���� ������
--����: SAMPLE_CITY - �������; CITY1 - ������ ����� ��� ���������; CITY2 - ������ ����� ��� ���������.
--�����: �������� ��������� ������.
FUNCTION DIFFERENT_CITY(
SAMPLE_CITY ROUTE.CITY1%TYPE,
CITY1 ROUTE.CITY1%TYPE,
CITY2 ROUTE.CITY1%TYPE)
RETURN ROUTE.CITY1%TYPE IS
BEGIN
IF SAMPLE_CITY = CITY1 THEN
RETURN CITY2;
ELSE
RETURN CITY1;
END IF;
END;

--������� ���� ��� ���� ����� ����� ���������� ��������.
--����: START_CITY - ������; FINISH_CITY - ����.
--�����: ������� ���� ����� �� START_CITY � FINISH_CITY.
FUNCTION FIND_PATH(
START_CITY ROUTE.CITY1%TYPE,
FINISH_CITY ROUTE.CITY2%TYPE)
RETURN ways_tab IS
--����������
v_distance NUMBER(10); --����������
v_wayStr VARCHAR2(100); --����
e_sameCity EXCEPTION;
new_rec way_rec;
--���������� � ������������� ��������� ������
pathsTab ways_tab := ways_tab();
foundPathTab ways_tab := ways_tab();
BEGIN
--���� ��� ������ ���� � ��� �� �����
IF START_CITY = FINISH_CITY THEN
RAISE e_sameCity;
ELSE
--������ ��������� ������� � ���������� ����� �� START_CITY
pathsTab := CREATE_START_PATH_TAB(START_CITY);

--������ ��� ���� �� FINISH_CITY
MAKE_NEXT_STEP(pathsTab, FINISH_CITY, foundPathTab);
FOR i IN pathsTab.FIRST..pathsTab.LAST LOOP
IF pathsTab(i).LASTCITY = FINISH_CITY THEN
new_rec.WSTR := pathsTab(i).WSTR;
new_rec.RESDIS := pathsTab(i).RESDIS;
new_rec.LASTCITY := FINISH_CITY;
foundPathTab.EXTEND;
foundPathTab(foundPathTab.LAST) := new_rec;
END IF;
END LOOP;
END IF;
RETURN foundPathTab;

EXCEPTION
WHEN e_sameCity THEN
DBMS_OUTPUT.PUT_LINE('������ ���� � ��� �� �����');
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('������ � �������� ������');
END FIND_PATH;

--��������� ������� ����� �������� ���� ����� ���������� ��������.
--����: START_CITY - ������; FINISH_CITY - ����.
PROCEDURE FIND_SHORTEST_PATH(
START_CITY ROUTE.CITY1%TYPE,
FINISH_CITY ROUTE.CITY2%TYPE) IS
minTRANSFER NUMBER(10):=100000;
minDist NUMBER(10):=10000;
shPathTab ways_tab := ways_tab();
BEGIN
--����� ��� ���� �� START_CITY � FINISH_CITY
shPathTab := FIND_PATH(START_CITY, FINISH_CITY);

FOR i IN shPathTab.FIRST..shPathTab.LAST LOOP
-- DBMS_OUTPUT.PUT_LINE(shPathTab(i).TRANSFERS);
IF LENGTH(shPathTab(i).WSTR) - LENGTH(REPLACE(shPathTab(i).WSTR, '�', ''))<minTRANSFER
THEN
minTRANSFER := LENGTH(shPathTab(i).WSTR) - LENGTH(REPLACE(shPathTab(i).WSTR, '�', ''));
END IF;
END LOOP;
DBMS_OUTPUT.PUT_LINE('�������� ����� ' || START_CITY || ' � ' || FINISH_CITY || ' � ���������� ����������� ���������: ');

FOR i IN shPathTab.FIRST..shPathTab.LAST LOOP
IF LENGTH(shPathTab(i).WSTR) - LENGTH(REPLACE(shPathTab(i).WSTR, '�', '')) = minTRANSFER THEN
--����� ���� �� �����
DBMS_OUTPUT.PUT_LINE(shPathTab(i).WSTR);
DBMS_OUTPUT.PUT_LINE('����� �������� - ' || shPathTab(i).RESDIS);
DBMS_OUTPUT.PUT_LINE('');
END IF;
END LOOP;

DBMS_OUTPUT.PUT_LINE('����������� ���������� ��������� - ' || minTRANSFER);
DBMS_OUTPUT.PUT_LINE('');

FOR i IN shPathTab.FIRST..shPathTab.LAST LOOP
IF LENGTH(shPathTab(i).WSTR) - LENGTH(REPLACE(shPathTab(i).WSTR, '�', '')) = minTRANSFER THEN
IF shPathTab(i).RESDIS<minDist THEN 
minDist:=shPathTab(i).RESDIS;
END IF;
END IF;
END LOOP;


DBMS_OUTPUT.PUT_LINE('������� � ���������� ������ � � ���������� ����������� ���������:');

FOR i IN shPathTab.FIRST..shPathTab.LAST LOOP
IF LENGTH(shPathTab(i).WSTR) - LENGTH(REPLACE(shPathTab(i).WSTR, '�', '')) = minTRANSFER 
AND minDist=shPathTab(i).RESDIS THEN
--����� ���� �� �����
DBMS_OUTPUT.PUT_LINE(shPathTab(i).WSTR);
DBMS_OUTPUT.PUT_LINE('����� �������� - ' || shPathTab(i).RESDIS);
END IF;
END LOOP;
END FIND_SHORTEST_PATH;

--������� ���������, �������� �� ���� ��� ���������� � ����� ���� ������ ������ (�.�. ���� �� ���� ����� � ������ STR)
--����: STR - ������ ����������� ����; CITY - �������� ������.
--�����: TRUE - ���� ����� ��� ������ � ������ ����; FALSE - ���� ����� ����������� �� ���� �������.
FUNCTION ISCYCLE(STR IN VARCHAR2, CITY IN ROUTE.CITY1%TYPE)
RETURN BOOLEAN IS
BEGIN
IF INSTR(STR, CITY) = 0 THEN
RETURN FALSE;
ELSE
RETURN TRUE;
END IF;
END ISCYCLE;

--��������� ��������� ��������� ��������� ��� ��� ���� �����
--����: WTAB - ��������� ������� �����; FINISH_CITY - ������� �����.
--�����: ��������� ��������� ������� WTAB
PROCEDURE MAKE_NEXT_STEP(
OLD_TAB IN ways_tab,
FINISH_CITY IN ROUTE.CITY2%TYPE,
FOUND_ROUTE IN OUT ways_tab) IS
new_tab ways_tab := ways_tab();
new_tab_rec way_rec;
--���� ������ ����� ��������� ��� ����, ������� ���������� ��� ������������� � ��������� ������
CURSOR c_way_from(CITY_FROM ROUTE.CITY1%TYPE) IS
SELECT CITY1,
CITY2, DIST
FROM ROUTE
WHERE CITY1 = CITY_FROM OR CITY2 = CITY_FROM;
TYPE t_path_rec IS RECORD(CITY1 ROUTE.CITY1%TYPE, CITY2 ROUTE.CITY2%TYPE, DIS ROUTE.DIST%TYPE);
path_rec t_path_rec;
next_city ROUTE.CITY1%TYPE;
BEGIN
--���������, ���������� �� ��� ������������� ���� �� FINISH_CITY (�.�. ����� �� ������� OLD_TAB). ���� ������� OLD_TAB �����, �� ������� �� ��������� MAKE_NEXT_STEP
IF OLD_TAB.COUNT = 0 THEN
RETURN;
END IF;
FOR i IN OLD_TAB.FIRST..OLD_TAB.LAST LOOP
--������� ��� ������ �� ��������� ������ �������� ����
OPEN c_way_from(OLD_TAB(i).LASTCITY);
LOOP
--���������� ��������� ������ ������ �� ������� c_way_from � ������������ � ����������� ���������� path_rec
FETCH c_way_from INTO path_rec;
EXIT WHEN c_way_from%NOTFOUND;
--���������� ��������� ����� �� ����
next_city := DIFFERENT_CITY(OLD_TAB(i).LASTCITY, path_rec.CITY1, path_rec.CITY2);
--���������, �������� �� ���� ��� ���������� � ������� ���� ������ next_city
IF ISCYCLE(OLD_TAB(i).WSTR, next_city) THEN
--���� ����� next_city ��� ��� ������� � ������� ����, �� ���������� ������ ������ � ��������� � ���������
CONTINUE;

END IF;
--�������� ����� ������ ��� ����� ������� �����
new_tab_rec.WSTR := OLD_TAB(i).WSTR || ' � ' || next_city;
new_tab_rec.RESDIS := OLD_TAB(i).RESDIS + path_rec.DIS;
new_tab_rec.LASTCITY := next_city;
IF next_city = FINISH_CITY THEN
--������� ������ � ������� ������� �����
FOUND_ROUTE.EXTEND;
FOUND_ROUTE(FOUND_ROUTE.LAST) := new_tab_rec;
ELSE
--������� ������ � ����� ������� �����
new_tab.EXTEND;
new_tab(new_tab.LAST) := new_tab_rec;
END IF;
END LOOP;
CLOSE c_way_from;
END LOOP;
--���������� �������� ��������� MAKE_NEXT_STEP ��� ������� ����� new_tab
MAKE_NEXT_STEP(new_tab, FINISH_CITY, FOUND_ROUTE);
END MAKE_NEXT_STEP;
END PATH3;

/

DECLARE
START_CITY ROUTE.CITY1%TYPE := '������';
FINISH_CITY ROUTE.CITY1%TYPE := '������������';
BEGIN
PATH3.FIND_SHORTEST_PATH(START_CITY, FINISH_CITY);
END;

