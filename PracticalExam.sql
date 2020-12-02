USE Cities
GO

IF OBJECT_ID ('ArchitectCity','U') IS NOT NULL
	DROP TABLE ArchitectCity

IF OBJECT_ID('City','U') IS NOT NULL
	DROP TABLE City

IF OBJECT_ID('Buildings','U') IS NOT NULL 
	DROP TABLE Buildings

IF OBJECT_ID('Bridges','U') IS NOT NULL
	DROP TABLE Bridges

IF OBJECT_ID('Architect','U') IS NOT NULL
	DROP TABLE Architect
GO

CREATE TABLE Architect 
(Aid INT PRIMARY KEY IDENTITY(1,1),
Forename VARCHAR(100),
Surname VARCHAR(100),
Experience INT)

CREATE TABLE Bridges 
(BRid INT PRIMARY KEY IDENTITY(1,1),
BRName VARCHAR(100),
YearOfConstruction INT,
Aid INT REFERENCES Architect(Aid))

CREATE TABLE Buildings
(BUid INT PRIMARY KEY IDENTITY(1,1),
BUName VARCHAR(100),
Height INT,
Description VARCHAR(400),
Aid INT REFERENCES Architect(Aid))

CREATE TABLE City 
(Cid INT PRIMARY KEY IDENTITY(1,1),
CName VARCHAR(100),
Population INT,
Area INT)

CREATE TABLE ArchitectCity
(Aid INT REFERENCES Architect(Aid),
Cid INT REFERENCES City(Cid),
StartDate VARCHAR(100),
EndDate VARCHAR(100),
Score INT,
PRIMARY KEY(Aid,Cid))

--stored procedure
GO
CREATE OR ALTER PROC uspNewRecord
		@Forename VARCHAR(100), @CName VARCHAR(100), @StartDate VARCHAR(100),
		@EndDate VARCHAR(100), @Score INT
AS
	DECLARE @Aid INT = (SELECT Aid
						FROM Architect
						WHERE Forename = @Forename),
			@Cid INT = (SELECT Cid
						FROM City
						WHERE CName = @CName)
IF @Aid IS NULL OR @Cid IS NULL
BEGIN 
	RAISERROR('No such architect',16,1)
	RETURN -1
END

IF EXISTS (SELECT *
		   FROM ArchitectCity
		   WHERE Aid = @Aid AND Cid = @Cid)
	UPDATE ArchitectCity
	SET StartDate = @StartDate, EndDate = @EndDate, Score = @Score
	WHERE Aid = @Aid AND Cid = @Cid
ELSE 
	INSERT ArchitectCity(Aid,Cid,StartDate,EndDate,Score)
	VALUES (@Aid,@Cid,@StartDate,@EndDate,@Score)
GO

--ARCHITECT
INSERT Architect
	VALUES ('Ion','Angelica',12),('Blaga','Ioana',8)

SELECT * FROM Architect

--BRIDGES
INSERT Bridges
	VALUES ('St. John',1980,1),('Anna Karenina',1990,1)

SELECT * FROM Bridges

--BUILDINGS
INSERT Buildings
	VALUES ('St. Constantin',10000,'private hospital',1),('St. Sophia',20000,'church',2)

SELECT * FROM Buildings

--CITY
INSERT City
	VALUES ('Brasov',550000,12),('London',8000000,20)

SELECT * FROM City

EXEC uspNewRecord 'Ion','Brasov','10.12.2017','10.12.2018',5
EXEC uspNewRecord 'Blaga','Brasov','15.12.2018','15.10.2019',3

SELECT * FROM ArchitectCity

--function
GO
CREATE OR ALTER FUNCTION ufFilterArchitects(@N INT)
RETURNS TABLE 
RETURN SELECT A.Forename
FROM Architect A
WHERE A.Aid IN
	(SELECT AC.Aid
	 FROM ArchitectCity AC
	 GROUP BY AC.Aid
	 HAVING COUNT(*) >= @N)
GO

SELECT * FROM ArchitectCity

SELECT * FROM ufFilterArchitects(2)
