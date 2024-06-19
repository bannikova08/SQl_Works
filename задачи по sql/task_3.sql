/*Для каждой таблицы схемы вывести: 
1) имя таблицы;
2) имя первого столбца первого (по алфавиту) ограничения уникальности; 
3) имя второго столбца первого ограничения уникальности; 
4) общее число столбцов в первом ограничении уникальности; 
5) имя первого столбца второго (по алфавиту) ограничения уникальности; 
6) имя второго столбца второго ограничения уникальности; 
7) общее число столбцов во втором ограничении уникальности; 
8) общее число ограничений уникальности.*/

DROP TABLE EXAMPLE;
CREATE TABLE EXAMPLE 
   (	"EMPLOYEE_ID" NUMBER(6,0), 
	"LAST_NAME" VARCHAR2(25 BYTE) NOT NULL ENABLE, 
	"EMAIL" VARCHAR2(25 BYTE), 
	"SALARY" NUMBER(8,2), 
	"COMMISSION_PCT" NUMBER(2,2), 
	"PHONE" VARCHAR2(25 BYTE), 
	 CONSTRAINT "EMAIL_LN_UK" UNIQUE ("EMAIL", "LAST_NAME"),
	 CONSTRAINT "SALARY_CP_UK" UNIQUE ("SALARY", "COMMISSION_PCT"),
  
	 CONSTRAINT "LAST_NAME_SL_UK" UNIQUE ("LAST_NAME", "SALARY"),
	 CONSTRAINT "PHONE_UK" UNIQUE ("PHONE"));

WITH
user_cons AS (SELECT table_name, constraint_name, constraint_type FROM USER_CONSTRAINTS WHERE constraint_type = 'U'),
/*Содержит имя таблиц, в которых содержатся уникальные ограничения, имя ограничения и тип ограничения*/
user_col AS
(SELECT table_name, constraint_name, column_name, position FROM USER_CONS_COLUMNS),
/*Содержит имя таблиц, имя ограничения, имя столбца, позицию столбца в ограничении*/
u_c AS
(SELECT con.table_name, con.constraint_name, col.column_name, col.position,
COUNT(con2.constraint_name) AS cons_order
FROM user_cons con
JOIN user_cons con2
ON con.table_name = con2.table_name
AND con.constraint_name >= con2.constraint_name
JOIN user_col col
ON con.table_name = col.table_name
AND con.constraint_name = col.constraint_name
GROUP BY con.table_name, con.constraint_name, col.column_name, col.position
ORDER BY table_name, constraint_name, column_name),
/*Первое соединение позволяет определить номер ограничения в таблице.
Второе соединение таблиц user_cons и user_col по имени таблицы и имени ограничения*/

u_c_col11 AS (SELECT table_name,column_name as "U_CONS1_COL1"
FROM u_c c
WHERE c.position =1 AND c.cons_order=1),

u_c_col12 AS (SELECT table_name,NVL(column_name,'-') as "U_CONS1_COL2"
FROM u_c c1
WHERE c1.position =2 AND c1.cons_order=1),

u_c_col_cnt1 AS (SELECT max(position) as "U_CONS1_COL_CNT", c.table_name
FROM u_c c
WHERE c.cons_order=1
GROUP BY c.table_name, c.constraint_name),

u_c_col21 AS (SELECT table_name,NVL(column_name,'-') as "U_CONS2_COL1"
FROM u_c c
WHERE c.position =1 AND c.cons_order=2),

u_c_col22 AS (SELECT table_name,NVL(column_name,'-') as "U_CONS2_COL2"
FROM u_c c
WHERE c.position =2 AND c.cons_order=2),

u_c_col_cnt2 AS (SELECT max(position) as "U_CONS2_COL_CNT", c.table_name
FROM u_c c
WHERE c.cons_order=2
GROUP BY c.table_name, c.constraint_name),

U_CNT as
(
SELECT cc.table_name, COUNT(DISTINCT acc.constraint_name) AS "U_CONS_CNT"
FROM user_cons cc
LEFT JOIN user_cons_columns acc ON cc.constraint_name = acc.constraint_name
GROUP BY cc.table_name
)

SELECT
t.table_name,
NVL(ucol1.U_CONS1_COL1, '-') as "U_CONS1_COL1",
NVL(ucol2.U_CONS1_COL2, '-')  as "U_CONS1_COL2",
RPAD(NVL(ucolc1.U_CONS1_COL_CNT, 0),18,' ') as "U_CONS1_COL_CNT",
RPAD(NVL(ucc21.U_CONS2_COL1, '-'), 18, ' ') as "U_CONS2_COL1",
NVL(ucc22.U_CONS2_COL2, '-') as "U_CONS2_COL2",
RPAD(NVL(ucolc2.U_CONS2_COL_CNT, 0),18,' ') as "U_CONS2_COL_CNT",
RPAD(NVL(ucc.U_CONS_CNT, 0),18,' ') as "U_CONS_CNT"
FROM user_tables t
JOIN u_c_col11 ucol1 on ucol1.table_name=t.table_name
LEFT JOIN u_c_col12 ucol2 on ucol2.table_name=t.table_name
LEFT JOIN u_c_col_cnt1 ucolc1 on ucolc1.table_name=t.table_name
LEFT JOIN u_c_col_cnt2 ucolc2 on ucolc2.table_name=t.table_name
LEFT JOIN u_c_col21 ucc21 on ucc21.table_name = t.table_name
LEFT JOIN u_c_col22 ucc22 on ucc22.table_name = t.table_name
LEFT JOIN U_CNT ucc on t.table_name = ucc.table_name
