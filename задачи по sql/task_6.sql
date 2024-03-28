/*������� ������� � �������� �������� ����������
�����. ��� ������� �� �������� � ���� ������� ���������
�������� � ���� �����: ������ ����� ������ � ������������ ����
�����, ������� ��������� � ������� �����������, ������ � �
������� ��������, � �������� � ���� �����.
*/

DROP TABLE T1;
CREATE TABLE T1 (ID NUMBER(5),
CONSTRAINT id_K
PRIMARY KEY (ID));
INSERT INTO T1 VALUES(3);
INSERT INTO T1 VALUES(11);
INSERT INTO T1 VALUES(1);
INSERT INTO T1 VALUES(8);
INSERT INTO T1 VALUES(9);
INSERT INTO T1 VALUES(6);
INSERT INTO T1 VALUES(23);

WITH C AS (
SELECT ID,ROWNUM R FROM T1
ORDER BY ID),
/*� C �������� ���� ����� �� �������� � �� ���������� ������.*/

C1 AS(SELECT SUBSTR(SYS_CONNECT_BY_PATH(ID, ','),2) STR, ID, LEVEL L
              FROM C
              START WITH ID = (SELECT MIN(ID) FROM C)
              CONNECT BY PRIOR ID < ID
            ),
/*������� ��� ������������������ ����� ����� �������, ������� ���������� � ������� �����*/     
B1 AS(SELECT SUBSTR(SYS_CONNECT_BY_PATH(ID, ','),2) STR, ID, LEVEL L
FROM C
START WITH ID = (SELECT MAX(ID) FROM C)
CONNECT BY PRIOR ID > ID
),         
/*������� ��� ������������������ ����� ����� �������, ������� ���������� � ���������� �����*/       

L AS (SELECT ID, STR
FROM C1 JOIN C
USING (ID)
WHERE L=R)
/*�������� ����� �������� ������������������ ������� ���� �����*/ 

SELECT  ID, TRIM (TRAILING ',' FROM STR||','|| SUBSTR(R,INSTR(',' || R|| ',', ','|| ID || ',') + LENGTH(ID) + 1)) AS "Result"
/*��������� ����� ����� ����� � ������, ������� ��������� ������ � ������� ����� ������� ����� � R */
FROM L, (SELECT STR R FROM B1 WHERE LENGTH(STR) = (SELECT MAX(LENGTH(STR)) FROM B1))
/*����� ������� ������������������ � �������� �������*/
ORDER BY ID;
