/*»меетс€ таблица с числовым столбцом первичного
ключа. ƒл€ каждого из значений в этом столбце требуетс€
получить в виде горки: перва€ часть строки Ч перечисление всех
чисел, меньших заданного в пор€дке возрастани€, втора€ Ч в
пор€дке убывани€, в середине Ч само число.
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
/*¬ C хран€тс€ наши числа по убывани€ и их пор€дковые номера.*/

C1 AS(SELECT SUBSTR(SYS_CONNECT_BY_PATH(ID, ','),2) STR, ID, LEVEL L
              FROM C
              START WITH ID = (SELECT MIN(ID) FROM C)
              CONNECT BY PRIOR ID < ID
            ),
/*¬ыводим все последовательности чисел через зап€тую, которые начинаютс€ с первого числа*/     
B1 AS(SELECT SUBSTR(SYS_CONNECT_BY_PATH(ID, ','),2) STR, ID, LEVEL L
FROM C
START WITH ID = (SELECT MAX(ID) FROM C)
CONNECT BY PRIOR ID > ID
),         
/*¬ыводим все последовательности чисел через зап€тую, которые начинаютс€ с последнего числа*/       

L AS (SELECT ID, STR
FROM C1 JOIN C
USING (ID)
WHERE L=R)
/*ѕолучаем перую половину последовательности включа€ само число*/ 

SELECT  ID, TRIM (TRAILING ',' FROM STR||','|| SUBSTR(R,INSTR(',' || R|| ',', ','|| ID || ',') + LENGTH(ID) + 1)) AS "Result"
/*—оедин€ем левую часть горки с правой, начина€ вхождение правой с зап€той после нужного числа в R */
FROM L, (SELECT STR R FROM B1 WHERE LENGTH(STR) = (SELECT MAX(LENGTH(STR)) FROM B1))
/*—ама€ длинна€ последовательность в обратном пор€дке*/
ORDER BY ID;
