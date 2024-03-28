/*Задана таблица ROUTE со столбцами:
ID NUMBER PRIMARY KEY,
CITY1 VARCHAR2(40),
CITY2 VARCHAR2(40),
DIST NUMBER,
где ID – уникальный номер, CITY1 и CITY2 – названия городов, DIST – расстояние между городами.
 Названия городов – уникальны.
Создать процедуру, которая позволит находить пути между двумя городами с наименьшим
количеством пересадок и выбирать среди них пути с наименьшей длиной.
Имена городов – параметры процедуры.
Программа должна предусматривать обработку исключений.
Пример представления результата для городов Псков и Вологда:
Маршруты между Псков и Вологда с наименьшим количеством пересадок
Псков – Калуга - Вологда Длина маршрута - 120
Псков - Вязьма - Вологда Длина маршрута - 200
Минимальное количество пересадок - 1
Маршрут с наименьшей длиной и с наименьшим количеством пересадок:
Псков – Калуга - Вологда Длина маршрута - 120*/

DROP TABLE ROUTE;
CREATE TABLE ROUTE (
ID NUMBER PRIMARY KEY,
CITY1 VARCHAR2(40),
CITY2 VARCHAR2(40),
DIST NUMBER(10)
);

--Заполнение таблицы
INSERT INTO ROUTE (ID, CITY1, CITY2, DIST) VALUES (1, 'Москва', 'Санкт-Петербург', 634);
INSERT INTO ROUTE (ID, CITY1, CITY2, DIST) VALUES (2, 'Санкт-Петербург', 'Екатеринбург', 2292);
INSERT INTO ROUTE (ID, CITY1, CITY2, DIST) VALUES (3, 'Москва','Казань', 809);
INSERT INTO ROUTE (ID, CITY1, CITY2, DIST) VALUES (4, 'Казань', 'Екатеринбург', 717);
INSERT INTO ROUTE (ID, CITY1, CITY2, DIST) VALUES (5, 'Екатеринбург', 'Иркутск', 2813);
INSERT INTO ROUTE (ID, CITY1, CITY2, DIST) VALUES (6, 'Москва', 'Сочи', 1620);
INSERT INTO ROUTE (ID, CITY1, CITY2, DIST) VALUES (7, 'Сочи', 'Иркутск', 4798);
INSERT INTO ROUTE (ID, CITY1, CITY2, DIST) VALUES (8, 'Сочи', 'Анапа', 1384);
INSERT INTO ROUTE (ID, CITY1, CITY2, DIST) VALUES (9, 'Москва', 'Краснодар', 1345);
INSERT INTO ROUTE (ID, CITY1, CITY2, DIST) VALUES (10, 'Краснодар', 'Анапа', 165);

COMMIT;

--Решение
--Спецификация пакета
/
CREATE OR REPLACE PACKAGE PATH3 IS
PROCEDURE FIND_SHORTEST_PATH(START_CITY ROUTE.CITY1%TYPE, FINISH_CITY ROUTE.CITY2%TYPE);
END PATH3;

--Тело пакета
/
CREATE OR REPLACE PACKAGE BODY PATH3 IS
--ПЕРЕМЕННЫЕ:
TYPE way_rec IS RECORD(WSTR VARCHAR2(100), RESDIS NUMBER(10), LASTCITY ROUTE.CITY1%TYPE);
TYPE ways_tab IS TABLE OF way_rec;
--ФУНКЦИИ И ПРОЦЕДУРЫ:
FUNCTION CREATE_START_PATH_TAB(START_CITY ROUTE.CITY1%TYPE) RETURN ways_tab;
FUNCTION DIFFERENT_CITY(SAMPLE_CITY ROUTE.CITY1%TYPE, CITY1 ROUTE.CITY1%TYPE, CITY2 ROUTE.CITY1%TYPE) RETURN ROUTE.CITY1%TYPE;
FUNCTION FIND_PATH(START_CITY ROUTE.CITY1%TYPE, FINISH_CITY ROUTE.CITY2%TYPE) RETURN ways_tab;
FUNCTION ISCYCLE(STR IN VARCHAR2, CITY IN ROUTE.CITY1%TYPE) RETURN BOOLEAN;
PROCEDURE MAKE_NEXT_STEP(OLD_TAB IN ways_tab, FINISH_CITY IN ROUTE.CITY2%TYPE, FOUND_ROUTE IN OUT ways_tab);

--Функция создаёт на основе таблицы ROUTE индексную таблицу всех дорог из города START_CITY.
--Вход: START_CITY - город, от которого нужно проложить путь.
--Выход: индексная таблица с путями из START_CITY
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
--Определяем следующий город
next_city := DIFFERENT_CITY(START_CITY, rec.CITY1, rec.CITY2);
--Создаём запись
v_wayRec.WSTR := START_CITY || ' — ' || next_city;
v_wayRec.RESDIS := rec.DIST;
v_wayRec.LASTCITY := next_city;
--v_wayRec.TRANSFERS := LENGTH(v_wayRec.WSTR) - LENGTH(REPLACE(v_wayRec.WSTR, '-', ''));
--Добавляем запись
temp_tab.EXTEND;
temp_tab(v_ind) := v_wayRec;
--Увеличиваем счётчик индекса таблицы
v_ind := v_ind + 1;
END LOOP;
RETURN temp_tab;
END CREATE_START_PATH_TAB;

--Функция определяет город, отличный от двух других
--Вход: SAMPLE_CITY - образец; CITY1 - первый город для сравнения; CITY2 - второй город для сравнения.
--Выход: название отличного города.
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

--Функция ищет все пути между двумя указанными городами.
--Вход: START_CITY - откуда; FINISH_CITY - куда.
--Выход: таблица всех путей из START_CITY в FINISH_CITY.
FUNCTION FIND_PATH(
START_CITY ROUTE.CITY1%TYPE,
FINISH_CITY ROUTE.CITY2%TYPE)
RETURN ways_tab IS
--Переменные
v_distance NUMBER(10); --расстояние
v_wayStr VARCHAR2(100); --путь
e_sameCity EXCEPTION;
new_rec way_rec;
--Объявление и инициализация вложенных таблиц
pathsTab ways_tab := ways_tab();
foundPathTab ways_tab := ways_tab();
BEGIN
--Если был указан один и тот же город
IF START_CITY = FINISH_CITY THEN
RAISE e_sameCity;
ELSE
--Создаём индексную таблицу с заготовкой путей из START_CITY
pathsTab := CREATE_START_PATH_TAB(START_CITY);

--Строим все пути до FINISH_CITY
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
DBMS_OUTPUT.PUT_LINE('Выбран один и тот же город');
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('Ошибка в веденных данных');
END FIND_PATH;

--Процедура находит самый короткий путь между указанными городами.
--Вход: START_CITY - откуда; FINISH_CITY - куда.
PROCEDURE FIND_SHORTEST_PATH(
START_CITY ROUTE.CITY1%TYPE,
FINISH_CITY ROUTE.CITY2%TYPE) IS
minTRANSFER NUMBER(10):=100000;
minDist NUMBER(10):=10000;
shPathTab ways_tab := ways_tab();
BEGIN
--Найдём все пути из START_CITY в FINISH_CITY
shPathTab := FIND_PATH(START_CITY, FINISH_CITY);

FOR i IN shPathTab.FIRST..shPathTab.LAST LOOP
-- DBMS_OUTPUT.PUT_LINE(shPathTab(i).TRANSFERS);
IF LENGTH(shPathTab(i).WSTR) - LENGTH(REPLACE(shPathTab(i).WSTR, '—', ''))<minTRANSFER
THEN
minTRANSFER := LENGTH(shPathTab(i).WSTR) - LENGTH(REPLACE(shPathTab(i).WSTR, '—', ''));
END IF;
END LOOP;
DBMS_OUTPUT.PUT_LINE('Маршруты между ' || START_CITY || ' и ' || FINISH_CITY || ' с наименьшим количеством пересадок: ');

FOR i IN shPathTab.FIRST..shPathTab.LAST LOOP
IF LENGTH(shPathTab(i).WSTR) - LENGTH(REPLACE(shPathTab(i).WSTR, '—', '')) = minTRANSFER THEN
--Вывод пути на экран
DBMS_OUTPUT.PUT_LINE(shPathTab(i).WSTR);
DBMS_OUTPUT.PUT_LINE('Длина маршрута - ' || shPathTab(i).RESDIS);
DBMS_OUTPUT.PUT_LINE('');
END IF;
END LOOP;

DBMS_OUTPUT.PUT_LINE('Минимальное количество пересадок - ' || minTRANSFER);
DBMS_OUTPUT.PUT_LINE('');

FOR i IN shPathTab.FIRST..shPathTab.LAST LOOP
IF LENGTH(shPathTab(i).WSTR) - LENGTH(REPLACE(shPathTab(i).WSTR, '—', '')) = minTRANSFER THEN
IF shPathTab(i).RESDIS<minDist THEN 
minDist:=shPathTab(i).RESDIS;
END IF;
END IF;
END LOOP;


DBMS_OUTPUT.PUT_LINE('Маршрут с наименьшей длиной и с наименьшим количеством пересадок:');

FOR i IN shPathTab.FIRST..shPathTab.LAST LOOP
IF LENGTH(shPathTab(i).WSTR) - LENGTH(REPLACE(shPathTab(i).WSTR, '—', '')) = minTRANSFER 
AND minDist=shPathTab(i).RESDIS THEN
--Вывод пути на экран
DBMS_OUTPUT.PUT_LINE(shPathTab(i).WSTR);
DBMS_OUTPUT.PUT_LINE('Длина маршрута - ' || shPathTab(i).RESDIS);
END IF;
END LOOP;
END FIND_SHORTEST_PATH;

--Функция проверяет, появится ли цикл при добавлении в конец пути нового города (т.е. есть ли этот город в строке STR)
--Вход: STR - строка пройденного пути; CITY - название города.
--Выход: TRUE - если город уже входит в данный путь; FALSE - если город встречается на пути впервые.
FUNCTION ISCYCLE(STR IN VARCHAR2, CITY IN ROUTE.CITY1%TYPE)
RETURN BOOLEAN IS
BEGIN
IF INSTR(STR, CITY) = 0 THEN
RETURN FALSE;
ELSE
RETURN TRUE;
END IF;
END ISCYCLE;

--Процедура добавляет следующий возможный шаг для всех путей
--Вход: WTAB - индексная таблица путей; FINISH_CITY - целевой город.
--Выход: изменённая индексная таблица WTAB
PROCEDURE MAKE_NEXT_STEP(
OLD_TAB IN ways_tab,
FINISH_CITY IN ROUTE.CITY2%TYPE,
FOUND_ROUTE IN OUT ways_tab) IS
new_tab ways_tab := ways_tab();
new_tab_rec way_rec;
--Этот курсор будет извлекать все пути, которые начинаются или заканчиваются в указанном городе
CURSOR c_way_from(CITY_FROM ROUTE.CITY1%TYPE) IS
SELECT CITY1,
CITY2, DIST
FROM ROUTE
WHERE CITY1 = CITY_FROM OR CITY2 = CITY_FROM;
TYPE t_path_rec IS RECORD(CITY1 ROUTE.CITY1%TYPE, CITY2 ROUTE.CITY2%TYPE, DIS ROUTE.DIST%TYPE);
path_rec t_path_rec;
next_city ROUTE.CITY1%TYPE;
BEGIN
--Проверяем, существуют ли ещё потенциальные пути до FINISH_CITY (т.е. пуста ли таблица OLD_TAB). Если таблица OLD_TAB пуста, то выходим из процедуры MAKE_NEXT_STEP
IF OLD_TAB.COUNT = 0 THEN
RETURN;
END IF;
FOR i IN OLD_TAB.FIRST..OLD_TAB.LAST LOOP
--Находим все дороги из конечного города текущего пути
OPEN c_way_from(OLD_TAB(i).LASTCITY);
LOOP
--Извлечение очередной строки данных из курсора c_way_from и присваивание её содержимого переменной path_rec
FETCH c_way_from INTO path_rec;
EXIT WHEN c_way_from%NOTFOUND;
--Определяем следующий город на пути
next_city := DIFFERENT_CITY(OLD_TAB(i).LASTCITY, path_rec.CITY1, path_rec.CITY2);
--Проверяем, появится ли цикл при добавлении в текущий путь города next_city
IF ISCYCLE(OLD_TAB(i).WSTR, next_city) THEN
--Если город next_city уже был пройден в текущем пути, то пропускаем данную дорогу и переходим к следующей
CONTINUE;

END IF;
--Составим новую запись для новой таблицы путей
new_tab_rec.WSTR := OLD_TAB(i).WSTR || ' — ' || next_city;
new_tab_rec.RESDIS := OLD_TAB(i).RESDIS + path_rec.DIS;
new_tab_rec.LASTCITY := next_city;
IF next_city = FINISH_CITY THEN
--Добавим запись в таблицу искомых путей
FOUND_ROUTE.EXTEND;
FOUND_ROUTE(FOUND_ROUTE.LAST) := new_tab_rec;
ELSE
--Добавим запись в новую таблицу путей
new_tab.EXTEND;
new_tab(new_tab.LAST) := new_tab_rec;
END IF;
END LOOP;
CLOSE c_way_from;
END LOOP;
--Рекурсивно вызываем процедуру MAKE_NEXT_STEP для таблицы путей new_tab
MAKE_NEXT_STEP(new_tab, FINISH_CITY, FOUND_ROUTE);
END MAKE_NEXT_STEP;
END PATH3;

/

DECLARE
START_CITY ROUTE.CITY1%TYPE := 'Москва';
FINISH_CITY ROUTE.CITY1%TYPE := 'Екатеринбург';
BEGIN
PATH3.FIND_SHORTEST_PATH(START_CITY, FINISH_CITY);
END;

