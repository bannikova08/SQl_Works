/*Дана таблица из двух столбцов ACTION и CODE, в
каждом из которых хранятся списки чисел, разделённых
пробелами. Создать запрос для разделения данных.
В результате выборки приняты обозначения: N_LIST —
порядковый номер списка в исходной таблице, N_POS —
порядковый номер числа в списке.*/

WITH A AS(
SELECT '47834 7387 378' ACTION, ' ' CODE FROM DUAL UNION ALL
SELECT '3782 73 87' ACTION, '284 928 ' CODE FROM DUAL UNION ALL
SELECT ' ' ACTION, ' ' CODE FROM DUAL), /*создаем таблицу*/
B AS(
SELECT ROWNUM RN, 0 LVL, REGEXP_REPLACE(ACTION, ' ','  ') ACTT,
REGEXP_REPLACE(CODE, ' ','  ') CODD
FROM A), 
C AS(SELECT DISTINCT RN, LEVEL LVL,
trim(REGEXP_SUBSTR(ACTT, '(^|\s)\S+(\s|$)',1,LEVEL)) ACT,
trim(REGEXP_SUBSTR(CODD, '(^|\s)\S+(\s|$)',1,LEVEL)) CD
FROM B
WHERE (LEVEL=1 and (regexp_like(actt,'\S')or regexp_like(codd,'\S')))
OR PRIOR RN=RN
CONNECT BY LEVEL<=REGEXP_COUNT(ACTT, '(^|\s)\S+(\s|$)')
OR LEVEL<=REGEXP_COUNT(CODD, '(^|\s)\S+(\s|$)')
ORDER BY RN, LVL
),
D AS (
SELECT * FROM C UNION ALL
SELECT * FROM B)
SELECT CASE
WHEN LVL=0 THEN TO_CHAR(RN)
ELSE ' '
END N_LIST, LVL N_POS, NVL(REGEXP_REPLACE(ACT, '  ', ' '),' ') ACTION, NVL(REGEXP_REPLACE(CD, '  ', ' '),' ') CODE FROM D
ORDER BY RN,2;
