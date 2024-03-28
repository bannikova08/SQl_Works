/*Создать программу для вывода различных чисел, полученных путём всех возможных перестановок цифр в числе,
которое задается как параметр. Дубликаты чисел и лидирующие нули не выводить. Например, если на вход подано число 303,
на печать должно быть выведено (порядок - любой):
303
330
33
*/

DECLARE

    stroka VARCHAR2(1000):= '&stroka'; 
    len  NUMBER;
    str stroka%TYPE;
    str1 stroka%TYPE;
    sign CHAR;
    search NUMBER;
    my_check NUMBER:=0;
    TYPE numbers IS TABLE OF NUMBER;
    my_numbers numbers:= numbers();
    max_val NUMBER;
    max_number stroka%TYPE;
    min_number stroka%TYPE;
    TYPE seq_table IS TABLE OF NUMBER;
    my_seq_table seq_table:= seq_table();
    check_1 EXCEPTION;
    check_2 EXCEPTION;
    
BEGIN
    /*удаление лишних пробелов*/
    stroka := replace(stroka, ' ', '');
    /*удаление ведущих нулей*/
    IF(REGEXP_LIKE(stroka, '^0+$'))  THEN
    stroka:=0;
    ELSE
    stroka := ltrim(stroka, '0');
    END IF;
    
    /*удаление знака + и -, запись '-' в переменную*/
    IF substr(stroka, 1, 1) in ('+', '-') THEN
    IF substr(stroka, 1, 1)='-'
        THEN sign:= '-';
    END IF;
        stroka := substr(stroka, 2);       
    END IF;
    
   
    /*если пользователь ввёл пустую строку*/
    IF stroka IS NULL THEN
        RAISE check_2;
    /*если пользователь ввёл строку, содержащую не только цифры*/
    ELSIF (regexp_like(stroka, '[^0-9]')) THEN   
        RAISE check_1;
    END IF;
    
    len := length(stroka);
    
    /*проходим по исходной строке и последовательно записываем в таблицу цифры введённого числа*/
    my_numbers.extend(len );
    str:= stroka;
    FOR i IN 1..len  LOOP
        my_numbers(i):= to_number(substr(str, 1, 1));
        str:= substr(stroka, i+1, len );
    END LOOP;
    
    /*сортировка по убыванию*/
    FOR j IN 1..len  LOOP
        FOR i IN 1.. len  - 1 LOOP
            IF (my_numbers(i) < my_numbers(i+1)) THEN
            max_val:= my_numbers(i);
            my_numbers(i):= my_numbers(i+1);
            my_numbers(i+1):= max_val;
            END IF;
        END LOOP;
    END LOOP;
    
    /*формирование максимального и минимального числа*/
    FOR i IN 1..len  LOOP
        max_number:= max_number || my_numbers(i);
        min_number:= min_number || my_numbers(len  +1-i);
    END LOOP;
 
 /*дополняем строку нулями слева при необходимости*/
 /*проверяем что в текущем числе содержатся все цифры из my_numbers*/
  FOR i IN min_number..max_number LOOP
        my_check:= 0;
        str1:= lpad(i, len , 0);
        FOR j IN 1..len  LOOP
            search:= instr(str1, my_numbers(j), 1);
           IF (search <> 0) THEN
            str1:= substr(str1, 1, search - 1) || substr(str1, search + 1, LENGTH(str1));
            my_check:= my_check + 1;
            END IF;
        END LOOP;
        
        IF (my_check = len ) THEN 
            /*добавляем во вложенную таблицу 1 элемент, а затем присваиваем ему значение*/
            my_seq_table.extend();
            my_seq_table(my_seq_table.COUNT):= i;
        END IF;
    END LOOP;
    
    /*вывод для пользователя*/
    /*если исходное число было отрицательным - конкатенируем знак "-" */  
        dbms_output.put_line('Число: ' || sign || stroka);
        dbms_output.put_line('');
        dbms_output.put_line('Все перестановки:');
    
FOR i IN my_seq_table.FIRST..my_seq_table.LAST LOOP
        dbms_output.put_line(sign|| my_seq_table(i)); 
    END LOOP;

EXCEPTION
    WHEN check_1 THEN 
    dbms_output.put_line('Строка не является числом');
    WHEN check_2 THEN 
    dbms_output.put_line('Пустая строка');
END;

