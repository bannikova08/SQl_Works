/*—оздать внешнюю таблицу дл€ чтени€ данных из текстового файла alert_xe.log. 
—оздать запрос к созданной внешней таблице, позвол€ющий получать информацию об
ошибках Oracle за определенный день мес€ца.*/

/*—оздаем внешнюю таблицу ALERT 
‘айл alert_xe.log находитс€ в директории STUD*/
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
/*—реди всех дат выберем ту, котора€ идЄт перед сообщением об ошибке*/
    TO_CHAR(MAX(
       TO_DATE(error_date.txt, 'Dy Mon DD HH24:MI:SS YYYY', 'nls_date_language=english')
    ), 'DD.MM.YYYY HH24:MI:SS') "Date", 
    error_text.txt "Error_text"
/*id записей с сообщением об ошибке*/    
FROM (
SELECT ROWID AS id, txt
    FROM alert
    WHERE txt LIKE 'ORA-%'
) error_text 

JOIN (
/*id записей со всеми датами, встречающимис€ в журнале*/
     SELECT ROWID AS id, txt
    FROM alert
    WHERE txt LIKE '___ ___ __ __:__:__ 20__'
) error_date
/*—оединив получим id дат идущих до сообщени€ об ошибке и id этой ошибки*/
ON (error_date.id < error_text.id)
GROUP BY error_text.id, error_text.txt
