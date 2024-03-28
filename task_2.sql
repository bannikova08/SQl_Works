/*���� ������� �� ���� ��������: 1 � ������, 2 � �����. ��������� �������� ������,
� ���������� �������� ������ ������ ������� ���������� �� ������� ���, ������� ���������� ��� �� �� ������ �������. */
/*������� ������� ������*/
DROP TABLE fruits1;
/*������� ������� ������*/

CREATE TABLE fruits1 (FSTR VARCHAR2(20) , FNUM NUMBER(5));

INSERT INTO fruits1 VALUES(NULL,2);

INSERT INTO fruits1 VALUES('banana',1);

INSERT INTO fruits1 VALUES('melon',4);

SELECT FSTR AS "������", FNUM AS "�����"
FROM fruits1;

SELECT NVL(TO_CHAR(FSTR),' ')"������"
FROM

/*�������� ������� �  ������������������� Rownum �� 1 �� ������������� ���������� ������� � �������*/
(SELECT ROWNUM NNUM
FROM fruits1 CROSS JOIN fruits1 CROSS JOIN fruits1 CROSS JOIN fruits1 CROSS JOIN fruits1
WHERE ROWNUM <= (SELECT MAX(FNUM) FROM fruits1)
) nums

/*��������� nums � ������ �� ������� ���������� ������� >= ������� nnum
����� �� ������� ���������� ������� ������ �� 1 �� ���-�� ������� � ������� ������*/
JOIN fruits1
ON FNUM >= nums.NNUM
/*��������� �� ��������*/
ORDER BY FSTR ASC;
