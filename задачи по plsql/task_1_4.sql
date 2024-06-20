/*Разработать программу, которая для произвольной таблицы определяла бы сумму входящих в нее цифр. 
Имя таблицы – параметр. Для решения использовать пакет DBMS_SQL.*/

DROP TABLE EXAMPLE1;
CREATE TABLE EXAMPLE1 (
    col1 NUMBER, 
    col2 NUMBER,
    col3 NUMBER,
    col4 DATE,
    col5 VARCHAR2(20),
    col6 DATE
);

INSERT INTO EXAMPLE1 (col1, col2, col3, col4, col5, col6) 
VALUES (1, 43, 23.3, NULL, 'Fd3', NULL);

INSERT INTO EXAMPLE1 (col1, col2, col3, col4, col5, col6) 
VALUES (NULL, 65, 103, NULL, 'Fdf6df', TO_DATE('01.11.2020','DD.MM.YYYY'));
SELECT* FROM EXAMPLE1;
/

ALTER SESSION SET NLS_DATE_FORMAT = 'DD.MM.YYYY';
CREATE OR REPLACE PROCEDURE calc_sum(table_name IN VARCHAR2) AS
    v_cursor PLS_INTEGER; -- переменная для идентификатора курсора
    v_result PLS_INTEGER; -- переменная для результата выполнения запроса
    v_col_value VARCHAR2(32000); -- переменная для значения столбца
    str VARCHAR2(32000):=''; -- переменная для хранения всех значений таблице
    total_sum number:=0; -- переменная для подсчета суммы
    v_col_count number:=0; -- переменная для подсчета количества столбцов в таблице
    no_table EXCEPTION;
   PRAGMA EXCEPTION_INIT(no_table, -00942);
   empty_table EXCEPTION;
   PRAGMA EXCEPTION_INIT(empty_table, -06502);
BEGIN
    v_cursor := DBMS_SQL.OPEN_CURSOR; -- Открытие курсора
   DBMS_SQL.PARSE(v_cursor, 'SELECT * FROM ' || table_name, DBMS_SQL.NATIVE);
      
   --подсчет количества столбцов в таблице
   LOOP
    v_col_count := v_col_count + 1;
    BEGIN
     DBMS_SQL.DEFINE_COLUMN(v_cursor, v_col_count, v_col_value,1000); -- пытаемся определить следующий столбец
    EXCEPTION
      WHEN OTHERS THEN
        EXIT; -- когда больше столбцов нет, выходим из цикла
    END;
  END LOOP;
  --DBMS_OUTPUT.PUT_LINE(v_col_count);
  
  --цикл по столбцам таблицы
     FOR i IN 1..v_col_count-1 LOOP
     v_result := DBMS_SQL.EXECUTE(v_cursor); -- Выполнение запроса
    DBMS_SQL.DEFINE_COLUMN(v_cursor, i, v_col_value,1000); -- Определение столбца для извлечения значений

    -- цикл обработки результатов запроса
    WHILE DBMS_SQL.FETCH_ROWS(v_cursor) > 0 LOOP
        DBMS_SQL.COLUMN_VALUE(v_cursor, i, v_col_value); -- получение значения столбца
       --DBMS_OUTPUT.PUT_LINE('Значение столбца: ' || TO_CHAR(v_col_value));
        --присоединяем значение текущей ячейки к строке
        str:=str||v_col_value;
    END LOOP;
    END LOOP;
  -- DBMS_OUTPUT.PUT_LINE(str);
    
    --определяем сумму цифр в строке str
     FOR i IN 1..LENGTH(str) LOOP
        IF SUBSTR(str, i, 1) BETWEEN '0' AND '9' THEN
            total_sum := total_sum + TO_NUMBER(SUBSTR(str, i, 1));
        END IF;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Cумма цифр, входящих в таблицу ' || table_name );
    DBMS_OUTPUT.PUT_LINE(total_sum);
    DBMS_SQL.CLOSE_CURSOR(v_cursor); 
    
 EXCEPTION
    WHEN empty_table THEN
        RAISE_APPLICATION_ERROR(-20001, 'Таблица ' || table_name || ' пустая');
    WHEN no_table THEN
        RAISE_APPLICATION_ERROR(-20003, 'Таблица ' || table_name || ' не существует');
    WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
END;
/

DECLARE
BEGIN
     calc_sum('EXAMPLE1');
END;
/
