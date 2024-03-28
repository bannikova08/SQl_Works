SELECT TO_CHAR(TO_DATE('&&N','DD.MM.SYYYY'), 'DD-MON-SYYYY', 'NLS_DATE_LANGUAGE = ENGLISH')  AS "�������� ����", /*������ �������� ����*/
CASE

WHEN TO_DATE('&N','DD.MM.SYYYY') <= TO_DATE('23.06.1877', 'DD.MM.SYYYY')THEN TO_CHAR(TO_DATE('23.06.1877', 'DD.MM.SYYYY'), 'DD-MON-SYYYY', 'NLS_DATE_LANGUAGE = ENGLISH')
/*���� ���� ������ ������� �������, �� ������� ���� ������� �������*/
WHEN TO_DATE('&N','DD.MM.SYYYY') > TO_DATE('21.06.9999', 'DD.MM.SYYYY')
THEN NULL
/*���� ���� ������ ������� 9999-�� ����, �� ���� ����� ����������*/
WHEN NEXT_DAY(TO_DATE(CONCAT('01.08',(TO_CHAR(TO_DATE('&N', 'DD.MM.SYYYY'),'SYYYY')))),'�����������')-42<TO_DATE('&N', 'DD.MM.SYYYY')
/*���� �������� ���� ������ ��������� ���� ������� ���� �� ���� ��� � �������� ����*/
THEN TO_CHAR(NEXT_DAY(TO_DATE(CONCAT('01.08',TO_CHAR(TO_NUMBER(TO_CHAR(TO_DATE('&N', 'DD.MM.SYYYY'),'SYYYY'))+1))),'�����������')-42, 'DD-MON-SYYYY', 'NLS_DATE_LANGUAGE = ENGLISH')
/*�� ���� ��������� ������, ������� ������� ��������� �����*/
ELSE TO_CHAR(NEXT_DAY(TO_DATE(CONCAT('01.08',(TO_CHAR(TO_DATE('&N', 'DD.MM.SYYYY'),'SYYYY')))),'�����������')-42, 'DD-MON-SYYYY', 'NLS_DATE_LANGUAGE = ENGLISH') END "���� ������ �������"
/*����� ���� ��������� ������, ������� ������� ���� �����*/
FROM DUAL;
UNDEFINE N;
/*������� �������� ����������*/