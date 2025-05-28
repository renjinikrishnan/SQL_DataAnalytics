
/* -------------------------------- Pre-processing ------------------------------ */

/*
BEFORE ANALYZING DATA, THE DATA MUST BE IN CORRECT FORMAT AND TYPE. THE DATA SHOULD BE CLEAN.

-- Alter data type of the columns accordingly
-- Add required columns for queries
-- Merge required columns
-- Removing null values
-- Setting primary keys
-- Setting foreign keys

*/

-- I have placed several fail safe code/checks before adding/ altering tables, these not necessary to be added, 
-- add these only if you want the script to be deployment ready. Else please just use the alter statements

USE [Finance Mortgage Loan Analysis]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

------------------------------------------------------------------------
/* BORROWERS TABLE */
------------------------------------------------------------------------


--CHANGE ZIPCODE DATA TYPE FROM INT TO VARCHAR

IF EXISTS (
    SELECT 1
    FROM sys.columns c
    JOIN sys.types t ON c.user_type_id = t.user_type_id
    WHERE c.object_id = OBJECT_ID('dbo.Borrowers')
      AND c.name = 'Zip'
      AND (
            t.name <> 'varchar' OR 
            c.max_length <> 6 OR
            c.is_nullable <> 1  -- 1 = NULLABLE, 0 = NOT NULL
          )
)
BEGIN
	alter table Borrowers alter column Zip varchar(6)
END
GO


--SETTING PRIMARY KEY IN THE BORROWERS TABLE

-- 1. Check for NULL values
IF EXISTS (SELECT 1 FROM Borrowers WHERE Borrower_Key IS NULL)
BEGIN
    PRINT 'Cannot set Primary Key in Borrowers table : Borrower_Key column contains NULL values.';
    RETURN;
END

-- 2. Check for duplicates
IF EXISTS(
	SELECT 1
	FROM Borrowers
	GROUP BY Borrower_Key
	HAVING COUNT(*) > 1
)
BEGIN
    PRINT 'Cannot set Primary Key in Borrowers table : Borrower_Key column contains duplicate values.';
    RETURN;
END

--3. Check for existing primary key
DECLARE @PK_Name NVARCHAR(128)
IF EXISTS(
	SELECT 1 
	FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
	WHERE tc.TABLE_NAME = 'Borrowers'
	and tc.CONSTRAINT_TYPE = 'primary key'
)
BEGIN
    PRINT 'Cannot set Primary Key in Borrowers table : Primary key already exists.';
    RETURN;
END

--4. Check for existing indexes
IF EXISTS (
    SELECT 1 
    FROM sys.indexes 
    WHERE object_id = OBJECT_ID('dbo.Borrowers') 
    AND name LIKE '%Borrower_Key%'
)
BEGIN
    PRINT 'There is an existing index on the column.';
	RETURN
END
ELSE
BEGIN
	ALTER TABLE Borrowers ADD CONSTRAINT PK_Borrowers_Borrower_key PRIMARY KEY (Borrower_Key)
END
GO




------------------------------------------------------------------------
/* LOAN TABLE */
------------------------------------------------------------------------


--ADDING YEAR COLUMN

IF NOT EXISTS (
    SELECT 1 
    FROM sys.columns 
    WHERE Name = N'Year_Ext' 
      AND Object_ID = OBJECT_ID(N'dbo.Loan')
)
BEGIN
	alter table Loan add Year_Ext as YEAR(Loan_Date) persisted
END


--ADDING MONTH COLUMN

IF NOT EXISTS (
	SELECT 1 
	FROM sys.columns
	where Name = N'Month_Ext'
	and OBJECT_ID = OBJECT_ID(N'dbo.Loan')
)
BEGIN
	alter table Loan add Month_Ext as MONTH(Loan_Date) persisted
END


--ADDING QUARTER COLUMN

IF NOT EXISTS (
	SELECT 1 
	FROM sys.columns
	where Name = N'Quarter_Ext'
	and OBJECT_ID = OBJECT_ID(N'dbo.Loan')
)
BEGIN
	alter table Loan add Quarter_Ext as DATEPART(QUARTER,Loan_Date) persisted
END


--ADDING DAY COLUMN

IF NOT EXISTS (
	SELECT 1 
	FROM sys.columns
	where Name = N'Day_Ext'
	and OBJECT_ID = OBJECT_ID(N'dbo.Loan')
)
BEGIN
	alter table Loan add Day_Ext as DAY(Loan_Date) persisted	
END


--ADDING MONTHNAME COLUMN
--Cannot use datename because it is non-deterministic

IF NOT EXISTS (
	SELECT 1 
	FROM sys.columns
	where Name = N'MonthName_Ext'
	and OBJECT_ID = OBJECT_ID(N'dbo.Loan')
)
BEGIN
	ALTER TABLE Loan
	ADD MonthName_Ext AS 
		CASE 
			WHEN MONTH(Loan_Date) = 1 THEN 'January'
			WHEN MONTH(Loan_Date) = 2 THEN 'February'
			WHEN MONTH(Loan_Date) = 3 THEN 'March'
			WHEN MONTH(Loan_Date) = 4 THEN 'April'
			WHEN MONTH(Loan_Date) = 5 THEN 'May'
			WHEN MONTH(Loan_Date) = 6 THEN 'June'
			WHEN MONTH(Loan_Date) = 7 THEN 'July'
			WHEN MONTH(Loan_Date) = 8 THEN 'August'
			WHEN MONTH(Loan_Date) = 9 THEN 'September'
			WHEN MONTH(Loan_Date) = 10 THEN 'October'
			WHEN MONTH(Loan_Date) = 11 THEN 'November'
			WHEN MONTH(Loan_Date) = 12 THEN 'December'
		END
		persisted;
END
GO

--ADDING PRIMARY KEY IN LOAN TABLE

-- 1. Check for NULL values
IF EXISTS (SELECT 1 FROM Loan WHERE Loan_Key IS NULL)
BEGIN
    PRINT 'Cannot set Primary Key in Loan table : Loan_Key column contains NULL values.';
    RETURN;
END

-- 2. Check for duplicates
IF EXISTS(
	SELECT 1
	FROM Loan
	GROUP BY Loan_Key
	HAVING COUNT(*) > 1
)
BEGIN
    PRINT 'Cannot set Primary Key in Loan table : Loan_Key column contains duplicate values.';
    RETURN;
END

--3. Check for existing primary key
IF EXISTS(
	SELECT 1 
	FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
	WHERE tc.TABLE_NAME = 'Loan'
	and tc.CONSTRAINT_TYPE = 'primary key'
)
BEGIN
    PRINT 'Cannot set Primary Key in Loan table : Primary key already exists.';
    RETURN;
END

--4. Check for existing indexes
IF EXISTS (
    SELECT 1 
    FROM sys.indexes 
    WHERE object_id = OBJECT_ID('dbo.Loan') 
    AND name LIKE '%Loan_Key%'
)
BEGIN
    PRINT 'There is an existing index on the column.';
	RETURN
END
ELSE
BEGIN
	ALTER TABLE Loan ADD CONSTRAINT PK_Loan_Loan_key PRIMARY KEY (Loan_Key)
END
GO



------------------------------------------------------------------------
/* Property Table */
------------------------------------------------------------------------


--ADD NEW COLUMN CITY_STATE BY MERGING CITY AND STATE

IF NOT EXISTS(
	SELECT 1
	FROM sys.columns
	WHERE name = N'City_State'
	AND OBJECT_ID = OBJECT_ID(N'dbo.Property')
)
BEGIN
	alter table Property add City_State as CONCAT(Property_City, ' ', Property_State) persisted
END
GO


--ADDING PRIMARY KEY IN PROPERTY TABLE

-- 1. Check for NULL values
IF EXISTS (SELECT 1 FROM Property WHERE Property_Key IS NULL)
BEGIN
    PRINT 'Cannot set Primary Key in Property table : Property_Key column contains NULL values.';
    RETURN;
END

-- 2. Check for duplicates
IF EXISTS(
	SELECT 1
	FROM Property
	GROUP BY Property_Key
	HAVING COUNT(*) > 1
)
BEGIN
    PRINT 'Cannot set Primary Key in Property table : Property_Key column contains duplicate values.';
    RETURN;
END

--3. Check for existing primary key
IF EXISTS(
	SELECT 1 
	FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
	WHERE tc.TABLE_NAME = 'Property'
	and tc.CONSTRAINT_TYPE = 'primary key'
)
BEGIN
    PRINT 'Cannot set Primary Key in Property table : Primary key already exists.';
    RETURN;
END

--4. Check for existing indexes
IF EXISTS (
    SELECT 1 
    FROM sys.indexes 
    WHERE object_id = OBJECT_ID('dbo.Property') 
    AND name LIKE '%Property_Key%'
)
BEGIN
    PRINT 'There is an existing index on the column.';
	RETURN
END
ELSE
BEGIN
	ALTER TABLE Property ADD CONSTRAINT PK_Property_Property_key PRIMARY KEY (Property_Key)
END
GO

-- RELATIONSHIP BETWEEN PROPERTY AND LOAN. 

--1. Convert the property_id column to not nullable
ALTER TABLE Property ALTER COLUMN Property_id SMALLINT NOT NULL


--2. Setting unique constriant on property_id
ALTER TABLE Property ADD CONSTRAINT UK_Property_id UNIQUE(property_id)
GO


------------------------------------------------------------------------
/* Financials Table */
------------------------------------------------------------------------


--REMOVE BLANK ROWS FROM THE TABLE
--select count(*) from Financials where Financial_Key is null

DELETE FROM Financials 
WHERE Financial_Key is null
GO


--ADDING PRIMARY KEY IN FINANCIALS TABLE

--Convert the financial_key column to not nullable
ALTER TABLE Financials ALTER COLUMN Financial_Key SMALLINT NOT NULL
GO

-- 1. Check for NULL values
IF EXISTS (SELECT 1 FROM Financials WHERE Financial_Key IS NULL)
BEGIN
    PRINT 'Cannot set Primary Key in Financials table : financial_Key column contains NULL values.';
    RETURN;
END

-- 2. Check for duplicates
IF EXISTS(
	SELECT 1
	FROM Financials
	GROUP BY Financial_Key
	HAVING COUNT(*) > 1
)
BEGIN
    PRINT 'Cannot set Primary Key in Financials table : Financial_Key column contains duplicate values.';
    RETURN;
END

--3. Check for existing primary key
IF EXISTS(
	SELECT 1 
	FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
	WHERE tc.TABLE_NAME = 'Financials'
	and tc.CONSTRAINT_TYPE = 'primary key'
)
BEGIN
    PRINT 'Cannot set Primary Key in Financials table : Primary key already exists.';
    RETURN;
END

--4. Check for existing indexes
IF EXISTS (
    SELECT 1 
    FROM sys.indexes 
    WHERE object_id = OBJECT_ID('dbo.Financials') 
    AND name LIKE '%Financial_Key%'
)
BEGIN
    PRINT 'There is an existing index on the column.';
	RETURN
END
ELSE
BEGIN
	ALTER TABLE Financials ADD CONSTRAINT PK_Financial_Financial_key PRIMARY KEY (Financial_Key)
END
GO

--SETTING FOREIGN KEYS TO SET UP RELATIONSHIPS

--The following checks should be done if this script needs to be prepared for deployment
--1. Check if FK already exists
--2. Make sure all child values exist in parent

--Please add these fail safe checks if needed, as in above queries

ALTER TABLE Financials ADD CONSTRAINT FK_Borrower_Key FOREIGN KEY (Borrower_Key) 
REFERENCES Borrowers(Borrower_Key)

ALTER TABLE Financials ADD CONSTRAINT FK_Property_Key FOREIGN KEY (Property_Key)
REFERENCES Property(Property_Key)

ALTER TABLE Financials ADD CONSTRAINT FK_Loan_Key FOREIGN KEY (Loan_Key) 
REFERENCES Loan(Loan_Key)



--SETTING FOREIGN KEY TO SET UP RELATIONSHIP
ALTER TABLE Loan ADD CONSTRAINT FK_Property_Property_ID 
FOREIGN KEY (Property_id) REFERENCES Property(Property_id)
GO


--CREATE VIEW WITH EXTRA COLUMN CALLED 'AGE', 'AGE BREAKDOWN' 
--** Better to create a view than to add non deterministic columns to the table

IF OBJECT_ID('dbo.vw_Borrowers_With_Age', 'V') IS NOT NULL
    DROP VIEW dbo.vw_Borrowers_With_Age;
GO

CREATE VIEW dbo.vw_Borrowers_With_Age AS
SELECT *,
    DATEDIFF(YEAR, DOB, CAST(GETDATE() AS DATE)) AS Age,
    CASE 
        WHEN DATEDIFF(YEAR, DOB, CAST(GETDATE() AS DATE)) >= 55 THEN '55 +'
        WHEN DATEDIFF(YEAR, DOB, CAST(GETDATE() AS DATE)) >= 45 THEN '45 - 54'
        WHEN DATEDIFF(YEAR, DOB, CAST(GETDATE() AS DATE)) >= 35 THEN '35 - 44'
        ELSE '18 - 34'
    END AS Age_Breakdown
FROM dbo.Borrowers;


