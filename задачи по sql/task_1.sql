SELECT TO_CHAR(TO_DATE('&&N','DD.MM.SYYYY'), 'DD-MON-SYYYY', 'NLS_DATE_LANGUAGE = ENGLISH')  AS "гЮДЮММЮЪ ДЮРЮ", /*ббндхл гюдюммсч дюрс*/
CASE

WHEN TO_DATE('&N','DD.MM.SYYYY') <= TO_DATE('23.06.1877', 'DD.MM.SYYYY')THEN TO_CHAR(TO_DATE('23.06.1877', 'DD.MM.SYYYY'), 'DD-MON-SYYYY', 'NLS_DATE_LANGUAGE = ENGLISH')
/*еякх дюрю лемэье оепбнцн рспмхпю, рн бшбндхл дюрс оепбнцн рспмхпю*/
WHEN TO_DATE('&N','DD.MM.SYYYY') > TO_DATE('21.06.9999', 'DD.MM.SYYYY')
THEN NULL
/*еякх дюрю анкэье рспмхпю 9999-цн цндю, рн дюрс мюирх мебнглнфмн*/
WHEN NEXT_DAY(TO_DATE(CONCAT('01.08',(TO_CHAR(TO_DATE('&N', 'DD.MM.SYYYY'),'SYYYY')))),'оНМЕДЕКЭМХЙ')-42<TO_DATE('&N', 'DD.MM.SYYYY')
/*еякх гюдюммюъ дюрю анкэье акхфюиьеи дюрш рспмхпю рнцн фе цндю врн х гюдюммюъ дюрю*/
THEN TO_CHAR(NEXT_DAY(TO_DATE(CONCAT('01.08',TO_CHAR(TO_NUMBER(TO_CHAR(TO_DATE('&N', 'DD.MM.SYYYY'),'SYYYY'))+1))),'оНМЕДЕКЭМХЙ')-42, 'DD-MON-SYYYY', 'NLS_DATE_LANGUAGE = ENGLISH')
/*рн хыел акхфюиьхи рспмхп, йнрнпши опнидер якедсчыхл кернл*/
ELSE TO_CHAR(NEXT_DAY(TO_DATE(CONCAT('01.08',(TO_CHAR(TO_DATE('&N', 'DD.MM.SYYYY'),'SYYYY')))),'оНМЕДЕКЭМХЙ')-42, 'DD-MON-SYYYY', 'NLS_DATE_LANGUAGE = ENGLISH') END "дЮРЮ МЮВЮКЮ РСПМХПЮ"
/*хмюве хыел акхфюиьхи рспмхп, йнрнпши опнидер щрхл кернл*/
FROM DUAL;
UNDEFINE N;
/*сдюкъел гмювемхе оепелеммни*/