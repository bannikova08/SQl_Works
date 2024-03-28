/*������� ��������� ��� ������ ��������� �����, ���������� ���� ���� ��������� ������������ ���� � �����,
������� �������� ��� ��������. ��������� ����� � ���������� ���� �� ��������. ��������, ���� �� ���� ������ ����� 303,
�� ������ ������ ���� �������� (������� - �����):
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
    /*�������� ������ ��������*/
    stroka := replace(stroka, ' ', '');
    /*�������� ������� �����*/
    IF(REGEXP_LIKE(stroka, '^0+$'))  THEN
    stroka:=0;
    ELSE
    stroka := ltrim(stroka, '0');
    END IF;
    
    /*�������� ����� + � -, ������ '-' � ����������*/
    IF substr(stroka, 1, 1) in ('+', '-') THEN
    IF substr(stroka, 1, 1)='-'
        THEN sign:= '-';
    END IF;
        stroka := substr(stroka, 2);       
    END IF;
    
   
    /*���� ������������ ��� ������ ������*/
    IF stroka IS NULL THEN
        RAISE check_2;
    /*���� ������������ ��� ������, ���������� �� ������ �����*/
    ELSIF (regexp_like(stroka, '[^0-9]')) THEN   
        RAISE check_1;
    END IF;
    
    len := length(stroka);
    
    /*�������� �� �������� ������ � ��������������� ���������� � ������� ����� ��������� �����*/
    my_numbers.extend(len );
    str:= stroka;
    FOR i IN 1..len  LOOP
        my_numbers(i):= to_number(substr(str, 1, 1));
        str:= substr(stroka, i+1, len );
    END LOOP;
    
    /*���������� �� ��������*/
    FOR j IN 1..len  LOOP
        FOR i IN 1.. len  - 1 LOOP
            IF (my_numbers(i) < my_numbers(i+1)) THEN
            max_val:= my_numbers(i);
            my_numbers(i):= my_numbers(i+1);
            my_numbers(i+1):= max_val;
            END IF;
        END LOOP;
    END LOOP;
    
    /*������������ ������������� � ������������ �����*/
    FOR i IN 1..len  LOOP
        max_number:= max_number || my_numbers(i);
        min_number:= min_number || my_numbers(len  +1-i);
    END LOOP;
 
 /*��������� ������ ������ ����� ��� �������������*/
 /*��������� ��� � ������� ����� ���������� ��� ����� �� my_numbers*/
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
            /*��������� �� ��������� ������� 1 �������, � ����� ����������� ��� ��������*/
            my_seq_table.extend();
            my_seq_table(my_seq_table.COUNT):= i;
        END IF;
    END LOOP;
    
    /*����� ��� ������������*/
    /*���� �������� ����� ���� ������������� - ������������� ���� "-" */  
        dbms_output.put_line('�����: ' || sign || stroka);
        dbms_output.put_line('');
        dbms_output.put_line('��� ������������:');
    
FOR i IN my_seq_table.FIRST..my_seq_table.LAST LOOP
        dbms_output.put_line(sign|| my_seq_table(i)); 
    END LOOP;

EXCEPTION
    WHEN check_1 THEN 
    dbms_output.put_line('������ �� �������� ������');
    WHEN check_2 THEN 
    dbms_output.put_line('������ ������');
END;

