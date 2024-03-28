/*������� ������� ������� ��� ������ ������ �� ���������� ����� alert_xe.log. 
������� ������ � ��������� ������� �������, ����������� �������� ���������� ��
������� Oracle �� ������������ ���� ������.*/

/*������� ������� ������� ALERT 
���� alert_xe.log ��������� � ���������� STUD*/
CREATE TABLE alert (
    txt VARCHAR(500)
    )
ORGANIZATION EXTERNAL (
    TYPE oracle_loader
    DEFAULT DIRECTORY stud
    ACCESS PARAMETERS (
RECORDS DELIMITED BY NEWLINE
FIELDS TERMINATED BY ','
MISSING FIELD VALUES ARE NULL
    )
    LOCATION ('alert_xe.log'))
REJECT LIMIT 0;

SELECT
/*����� ���� ��� ������� ��, ������� ��� ����� ���������� �� ������*/
    TO_CHAR(MAX(
       TO_DATE(error_date.txt, 'Dy Mon DD HH24:MI:SS YYYY', 'nls_date_language=english')
    ), 'DD.MM.YYYY HH24:MI:SS') "Date", 
    error_text.txt "Error_text"
/*id ������� � ���������� �� ������*/    
FROM (
SELECT ROWID AS id, txt
    FROM alert
    WHERE txt LIKE 'ORA-%'
) error_text 

JOIN (
/*id ������� �� ����� ������, �������������� � �������*/
     SELECT ROWID AS id, txt
    FROM alert
    WHERE txt LIKE '___ ___ __ __:__:__ 20__'
) error_date
/*�������� ������� id ��� ������ �� ��������� �� ������ � id ���� ������*/
ON (error_date.id < error_text.id)
GROUP BY error_text.id, error_text.txt
