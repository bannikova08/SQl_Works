/*Дана таблица из двух столбцов: 1 — строка, 2 — число. Требуется написать запрос,
в результате которого каждая строка таблицы выдавалась бы столько раз, сколько определено для неё во втором столбце. */
/*Удаляем таблицу фрукты*/
DROP TABLE fruits1;
/*Создаем таблицу фрукты*/

CREATE TABLE fruits1 (FSTR VARCHAR2(20) , FNUM NUMBER(5));

INSERT INTO fruits1 VALUES(NULL,2);

INSERT INTO fruits1 VALUES('banana',1);

INSERT INTO fruits1 VALUES('melon',4);

SELECT FSTR AS "Строка", FNUM AS "Число"
FROM fruits1;

SELECT NVL(TO_CHAR(FSTR),' ')"Строка"
FROM

/*Получаем таблицу с  последовательностью Rownum от 1 до максимального количества фруктов в таблице*/
(SELECT ROWNUM NNUM
FROM fruits1 CROSS JOIN fruits1 CROSS JOIN fruits1 CROSS JOIN fruits1 CROSS JOIN fruits1
WHERE ROWNUM <= (SELECT MAX(FNUM) FROM fruits1)
) nums

/*Соединяем nums и фрукты по условию количество фруктов >= столбец nnum
Тогда мы получим количество каждого фрукта от 1 до кол-ва фруктов в таблице фрукты*/
JOIN fruits1
ON FNUM >= nums.NNUM
/*Сортируем по алфавиту*/
ORDER BY FSTR ASC;
