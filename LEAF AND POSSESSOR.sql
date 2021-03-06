DECLARE @TEMPTBL TABLE(ID INT IDENTITY(1,1) PRIMARY KEY,
						PARENTTABLE NVARCHAR(100),
						CHILDTABLE NVARCHAR(100),
						PARENTCOLUMN NVARCHAR(100),
						CHILDCOLUMN NVARCHAR(100),
						POSSESSOR NVARCHAR(100),
						LEAF INT)

INSERT INTO @TEMPTBL(LEAF,CHILDTABLE,CHILDCOLUMN)
VALUES(1,'HOTEL','ID')

DECLARE @CURRENTLEVEL INT = 1
DECLARE @VARIABLE INT = 1

WHILE 1=1
BEGIN
	
	INSERT INTO @TEMPTBL(LEAF,CHILDTABLE,CHILDCOLUMN,PARENTTABLE,PARENTCOLUMN)
	SELECT @CURRENTLEVEL + 1,CT.name AS CHILDTABLE,CC.name AS CHILDCOLUMN,PT.name as PARENTTABLE,PC.name AS PARENTCOLUMN
	FROM sys.foreign_key_columns KC 
	INNER JOIN sys.tables  PT ON PT.[object_id] = KC.referenced_object_id
	INNER JOIN sys.columns PC ON PC.[object_id] = KC.referenced_object_id AND PC.column_id = KC.referenced_column_id
	INNER JOIN sys.tables  CT ON CT.[object_id] = KC.parent_object_id
	INNER JOIN sys.columns CC ON CC.[object_id] = KC.parent_object_id AND CC.column_id = KC.parent_column_id

	WHERE PT.[name] IN(SELECT CHILDTABLE FROM @TEMPTBL WHERE LEAF = @CURRENTLEVEL)
	 AND CT.name NOT IN(SELECT CHILDTABLE FROM @TEMPTBL)

	IF NOT EXISTS(SELECT TOP(1) 1 FROM @TEMPTBL WHERE LEAF = @CURRENTLEVEL) 
		  BREAK	
	SET @CURRENTLEVEL = @CURRENTLEVEL + 1
END

--select PARENTTABLE from @TEMPTBL group by PARENTTABLE

DECLARE @FIRST NVARCHAR(1000) = 'HOTEL'
DECLARE @VALUE INT = 1

--POSSESSOR BULMA  
DECLARE @DEGER NVARCHAR(1000) 
DECLARE CRS CURSOR LOCAL FOR
SELECT PARENTTABLE FROM @TEMPTBL ORDER BY ID OFFSET 1 ROWS

OPEN CRS
FETCH NEXT FROM CRS INTO @DEGER

WHILE @@FETCH_STATUS =0
    BEGIN

		 IF @DEGER = @FIRST
			UPDATE @TEMPTBL SET POSSESSOR = @VALUE WHERE PARENTTABLE = @DEGER 

		ELSE
			BEGIN 
			SET @FIRST = @DEGER 
			SET @VALUE = @VALUE +1
			UPDATE @TEMPTBL SET POSSESSOR = @VALUE WHERE PARENTTABLE = @DEGER 
			END

			
FETCH NEXT FROM CRS INTO @DEGER
    END
CLOSE CRS
DEALLOCATE CRS


--LEA BULMA

DECLARE @DENEME INT = 1	    --BASLANGIÇ POSSESSOR DEGERIM
DECLARE @DENEME2 INT = 1	--SIRAYLA ARTAN HER POSSESSORDA SIFIRLANAN LEAF DEGERIM
DECLARE @SIRA INT = 2		--ID SIRASI ILK POSSESSOR NULL OLDUGU ICIN 2DEN BASLIYOR
DECLARE @POSDEGERIM INT 
DECLARE CRS2 CURSOR LOCAL FOR 
SELECT POSSESSOR FROM @TEMPTBL ORDER BY ID OFFSET 1 ROWS

OPEN CRS2
FETCH NEXT FROM CRS2 INTO @POSDEGERIM
WHILE @@FETCH_STATUS =0
    BEGIN	
	 IF  @POSDEGERIM = @DENEME  --POS DEGERI SÜRESINCE
			BEGIN
			UPDATE @TEMPTBL SET LEAF = @DENEME2 WHERE ID= @SIRA
			SET @SIRA = @SIRA + 1
			SET @DENEME2 = @DENEME2 +1
			END
		
		ELSE 
		BEGIN
		SET @DENEME2 = 1    --FARKLI BIR POSSESSOR IÇIN LEAF'I TEKRARDAN 1 YAPTIM 
		SET @DENEME = @POSDEGERIM  --POSSESSOR DEGISTIRME IFTEKI KONTROL ICIN
		UPDATE @TEMPTBL SET LEAF = @DENEME2 WHERE ID =@SIRA
		SET @DENEME2 = @DENEME2 +1
		SET @SIRA = @SIRA +1
        END

FETCH NEXT FROM CRS2 INTO @POSDEGERIM
    END 
CLOSE CRS2

SELECT * 
FROM @TEMPTBL WHERE CHILDTABLE LIKE 'RES_DAY%'

SELECT * 
FROM @TEMPTBL WHERE PARENTTABLE LIKE 'RES_DAY%'




