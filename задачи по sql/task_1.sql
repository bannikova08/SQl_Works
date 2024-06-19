/*Определить дату начала ближайшего к заданной дате
Уимблдонского турнира, который начинается за шесть недель до
первого понедельника августа. Если заданная дата совпадает с
датой начала турнира в этом году, вывести её.*/

SELECT TO_CHAR(TO_DATE('&&N','DD.MM.SYYYY'), 'DD-MON-SYYYY', 'NLS_DATE_LANGUAGE = ENGLISH')  AS "Заданная дата", /*ВВОДИМ ЗАДАННУЮ ДАТУ*/
CASE

WHEN TO_DATE('&N','DD.MM.SYYYY') <= TO_DATE('23.06.1877', 'DD.MM.SYYYY')THEN TO_CHAR(TO_DATE('23.06.1877', 'DD.MM.SYYYY'), 'DD-MON-SYYYY', 'NLS_DATE_LANGUAGE = ENGLISH')
/*ЕСЛИ ДАТА МЕНЬШЕ ПЕРВОГО ТУРНИРА, ТО ВЫВОДИМ ДАТУ ПЕРВОГО ТУРНИРА*/
WHEN TO_DATE('&N','DD.MM.SYYYY') > TO_DATE('21.06.9999', 'DD.MM.SYYYY')
THEN NULL
/*ЕСЛИ ДАТА БОЛЬШЕ ТУРНИРА 9999-ГО ГОДА, ТО ДАТУ НАЙТИ НЕВОЗМОЖНО*/
WHEN NEXT_DAY(TO_DATE(CONCAT('01.08',(TO_CHAR(TO_DATE('&N', 'DD.MM.SYYYY'),'SYYYY')))),'Понедельник')-42<TO_DATE('&N', 'DD.MM.SYYYY')
/*ЕСЛИ ЗАДАННАЯ ДАТА БОЛЬШЕ БЛИЖАЙШЕЙ ДАТЫ ТУРНИРА ТОГО ЖЕ ГОДА ЧТО И ЗАДАННАЯ ДАТА*/
THEN TO_CHAR(NEXT_DAY(TO_DATE(CONCAT('01.08',TO_CHAR(TO_NUMBER(TO_CHAR(TO_DATE('&N', 'DD.MM.SYYYY'),'SYYYY'))+1))),'Понедельник')-42, 'DD-MON-SYYYY', 'NLS_DATE_LANGUAGE = ENGLISH')
/*ТО ИЩЕМ БЛИЖАЙШИЙ ТУРНИР, КОТОРЫЙ ПРОЙДЕТ СЛЕДУЮЩИМ ЛЕТОМ*/
ELSE TO_CHAR(NEXT_DAY(TO_DATE(CONCAT('01.08',(TO_CHAR(TO_DATE('&N', 'DD.MM.SYYYY'),'SYYYY')))),'Понедельник')-42, 'DD-MON-SYYYY', 'NLS_DATE_LANGUAGE = ENGLISH') END "Дата начала турнира"
/*ИНАЧЕ ИЩЕМ БЛИЖАЙШИЙ ТУРНИР, КОТОРЫЙ ПРОЙДЕТ ЭТИМ ЛЕТОМ*/
FROM DUAL;
UNDEFINE N;
/*УДАЛЯЕМ ЗНАЧЕНИЕ ПЕРЕМЕННОЙ*/
