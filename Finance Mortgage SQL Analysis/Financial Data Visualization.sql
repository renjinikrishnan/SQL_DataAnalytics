
 /************************************ DATA VISUALIZATIONS ************************************/




  /************************************ OVERVIEW PAGE ************************************/

-- **QUESTION 1**: TOP 5 STATES WITH THE HIGHEST TOTAL LOAN AMOUNTS IN 2019.
 -----------------------------------------------------------------------------------------------

 SELECT top 5  B.State, SUM(F.Loan_Amount) AS [Total Loan Amount],
		ROUND( CAST(SUM(F.Loan_Amount) * 100.0 / SUM(SUM(F.Loan_Amount)) OVER () AS DECIMAL(10,8)), 2)  AS [% Total_Loan]
		FROM Borrowers B
		JOIN Financials F ON B.Borrower_Key = F.Borrower_Key
		GROUP BY B.State
		ORDER BY 2 DESC;

/*
NOTES:
	CA, NY, PA, MI AND KY ARE THE FIRST 5 STATES WITH LARGE LOAN AMOUNTS, 
	TOP 3 STATES HAVE MORE THAN 6% OF TOTAL LOAN AMOUNT
*/


-- **QUESTION 2**: AGE GROUP WITH THE HIGHEST TOTAL LOAN AMOUNT.
 -----------------------------------------------------------------------------------------------
 
 SELECT V.Age_Breakdown, 
	SUM(F.Loan_Amount) AS [Total Loan Amount],
	CAST( (SUM(F.Loan_Amount) * 100.0) / SUM(SUM(F.Loan_Amount)) OVER() AS DECIMAL(10,2)) AS [% Total Loan Amount]
	FROM dbo.vw_Borrowers_With_Age V
	JOIN Financials F ON V.Borrower_Key = F.Borrower_Key
	GROUP BY V.Age_Breakdown
	ORDER BY 2 DESC;


/*
NOTES:
	55 + AGE GROUPS TAKE MORE LOANS AND MAKE UP CLOSE 50% OF TOTAL LOAN AMOUNT
*/


 /************************************ LOAN APPROVALS PAGE ************************************/

 

-- **QUESTION 1**: EFFECT OF LOAN PURPOSE ON CREDIT APPROVAL.
 -----------------------------------------------------------------------------------------------

SELECT 
	Purpose_of_Loan,
	Property_Usage,
	count(*)
	FROM Loan 
	WHERE Credit_Card_Authorization = 'Yes'
	GROUP BY Purpose_of_Loan, Property_Usage
	order by Purpose_of_Loan;


/*
NOTES:
	LOANS WITH THE 'PURCHASE' PURPOSE HAD THE HIGHEST NUMBER OF CREDIT APPROVALS, 
	PARTICULARLY FOR PRIMARY RESIDENCE PURCHASES.
*/


-- **QUESTION 2** AGE GROUP HAS HIGHEST LOAN AMOUNT ACROSS STATES
 -----------------------------------------------------------------------------------------------

WITH StateTotal AS (							--temp table - Get the [Total Loan Amount] for each state
    SELECT 
        V.State,
        SUM(F.Loan_Amount) AS [Total Loan Amount]
    FROM vw_Borrowers_With_Age V
    JOIN Financials F ON V.Borrower_Key = F.Borrower_Key
    GROUP BY V.State
),
StateRanked AS (								--temp table - Get the RANK based on the above [Total Loan Amount]
    SELECT 
        S.State,
        S.[Total Loan Amount],
        DENSE_RANK() OVER (ORDER BY [Total Loan Amount] DESC) AS [State Rank]
    FROM StateTotal S
),
Detailed AS (									--temp table - Get all the columns from joining the View and Financials
    SELECT 
        V.State, 
        V.Age_Breakdown, 
        SUM(F.Loan_Amount) AS [Total Loan Amount]
    FROM vw_Borrowers_With_Age V
    JOIN Financials F ON V.Borrower_Key = F.Borrower_Key
    GROUP BY V.State, V.Age_Breakdown
)
SELECT											--Join temp tables - Get required columns with the rank based on the state 
    D.State,
    D.Age_Breakdown,
    D.[Total Loan Amount],
    R.[State Rank]
FROM Detailed D
JOIN StateRanked R ON D.State = R.State
ORDER BY R.[State Rank], D.[Total Loan Amount] DESC;


/*
NOTES:
	CA, NY AND PA ARE THE TOP 3 STATES THAT HAS MAX LOAN AMOUNT. IN ALL OF THESE STATE 55+ COMMUNITY 
	TAKES UP MORE LOANS AND OUTWITS OTHER COMMUNITIES WITH CONSIDERABLE MARGIN
*/


-- **QUESTION 3** INDIVIDUALS BELONGING TO WHICH MARITAL STATUS TAKE MAXIMUM LOAN
 -----------------------------------------------------------------------------------------------

 SELECT B.Marital_Status,
	SUM(F.Loan_Amount) AS [TOTAL LOAN AMOUNT],
	CAST( ( SUM(F.Loan_Amount) * 100.0 ) / SUM(SUM(F.Loan_Amount)) OVER() AS DECIMAL(10,2) ) AS [% TOTAL LOAN AMOUNT] 
	FROM Borrowers B
	JOIN Financials F ON B.Borrower_Key = F.Borrower_Key
	GROUP BY B.Marital_Status
	ORDER BY 2 DESC;



/*
NOTES:
	MARRIED COUPLES ACCOUNT FOR 56% OF THE TOTAL LOAN AMOUNT, 
	FOLLOWED BY SINGLE INDIVIDUALS AT AROUND 15%, MARKING A SIGNIFICANT DIFFERENCE
*/


-- **QUESTION 4** WHICH GENDER HAS THE HIGHEST LOAN AMOUNT
 -----------------------------------------------------------------------------------------------


 SELECT 
	B.Sex,
	SUM(F.Loan_Amount) AS [TOTAL LOAN AMOUNT],
	CAST( ( (SUM(F.Loan_Amount) * 100.0) / SUM(SUM(F.Loan_Amount)) OVER() ) AS DECIMAL(10,2) ) AS [% TOTAL LOAN AMOUNT]
	FROM Borrowers B
	JOIN Financials F ON B.Borrower_Key = F.Borrower_Key
	GROUP BY B.Sex
	ORDER BY 2 DESC;



/*
NOTES:
	FEMALE CUSTOMERS MAKE UP ALMOST DOUBLE THE % TOTAL LOAN MAOUNT OF MALES 
*/


-- **QUESTION 5** FOR WHAT PURPOSE HAVE PEOPLE TAKE THE HIGHEST AMOUNT OF LOAN. IS IT RENT OR OWN? 
 -----------------------------------------------------------------------------------------------


WITH TEMP_TOT_AMOUNT AS(				--temp table - Get total amount based on Purpose_of_Loan
	SELECT 
		L.Purpose_of_Loan,
		SUM(F.Loan_Amount) AS [TOTAL LOAN AMOUNT]
		FROM Loan L
		JOIN Financials F ON L.Loan_Key = F.Loan_Key
		GROUP BY L.Purpose_of_Loan
),
TEMP_DENSE_RANK AS(						--temp table - Get dense rank based on above total amount
	SELECT 
		T.Purpose_of_Loan,
		T.[TOTAL LOAN AMOUNT],
		DENSE_RANK() OVER(ORDER BY T.[TOTAL LOAN AMOUNT] DESC) AS [TOTAL RANK]
		FROM TEMP_TOT_AMOUNT T
)
, 
TEMP_BORR_FINAN_LOAN AS (				--temp table - Get all the columns needed.
	SELECT 
		L.Purpose_of_Loan,
		L.Rent_or_Own,
		SUM(F.Loan_Amount) AS [TOT LOAN AMOUNT],
		T.[TOTAL RANK]
		FROM Loan L
		JOIN Financials F ON F.Loan_Key = L.Loan_Key
		JOIN TEMP_DENSE_RANK T ON T.Purpose_of_Loan = L.Purpose_of_Loan
		GROUP BY L.Purpose_of_Loan, L.Rent_or_Own, T.[TOTAL RANK]
)
SELECT * FROM TEMP_BORR_FINAN_LOAN ORDER BY [TOTAL RANK], [TOT LOAN AMOUNT] DESC;



/*
NOTES:
	TOTAL LOAN AMOUNT IS HIGHEST FOR PURCHASING AND CONSTRUCTING HOMES. PEOPLE TAKE LOANS FOR PURCHASING AND 
	CONSTRUCTING THEIR OWN HOMES. OVERALL, LOANS ARE TAKEN FOR 'OWN' PROPERTIES IRRESPECTIVE OF THE PURPOSE OF THE LOAN.
*/


  /************************************ BORROWER PAGE ************************************/

 --  **QUESTION 1** RELATIONSHIP BETWEEN LOAN AMOUNTS AND MONTHLY INCOME BY YEAR AND MONTH.
 -----------------------------------------------------------------------------------------------


 SELECT 
	YEAR(L.Loan_Date) AS [YEAR] , 
	DATENAME(MONTH, L.Loan_Date) AS [MONTH],
	SUM(F.Loan_Amount) AS [TOTAL_LOAN_AMOUNT],
	SUM(F.Monthly_Income) AS [TOTAL_MONTHLY_INCOME]
	FROM Financials F
	JOIN Loan L ON F.Loan_Key = L.Loan_Key
	GROUP BY YEAR(L.Loan_Date), DATENAME(MONTH, L.Loan_Date), MONTH(L.Loan_Date)
	ORDER BY 1, MONTH(L.Loan_Date);


/*
NOTES:
	THE TREND SHOWS THAT [TOTAL LOAN AMOUNT] AND [TOTAL MONTHLY AMOUNT] ARE PROPORTIONATE, 
	THAT IS WHEN [TOTAL MONTHLY AMOUNT] INCREASES [TOTAL LOAN AMOUNT] INCREASES AND VICE VERSA

	HIGHER MONTHLY INCOME CORRELATES WITH HIGHER LOAN APPROVALS, 
	INDICATING THE IMPORTANCE OF FINANCIAL STABILITY IN SECURING LARGER LOANS.
*/


 -- **QUESTION 2** WHAT IS THE TOTAL LOAN AMOUNT FOR 2019
 -----------------------------------------------------------------------------------------------

 SELECT 
	SUM(Loan_Amount) AS [TOTAL_LOAN_AMOUNT]
	FROM Financials;


  -- **QUESTION 3** WHAT IS THE TOTAL MONTHLY INCOME FOR 2019
 -----------------------------------------------------------------------------------------------

 SELECT
	SUM(Monthly_Income) AS [TOTAL_MONTHLY_INCOME]
	FROM Financials;


  -- **QUESTION 4** WHAT IS THE TOTAL MONTHLY INCOME FOR 2019
 -----------------------------------------------------------------------------------------------

 SELECT 
	SUM(Savings) AS [TOTAL_SAVINGS]
	FROM Financials;



/************************************ PROPERTY PAGE ************************************/


-- **QUESTION 1** WHAT IS THE TOTAL MONTHLY INCOME FOR 2019
 -----------------------------------------------------------------------------------------------


WITH TEMP_TOTAL_LOAN_AMOUNT AS (
	SELECT 
		B.State,
		SUM(F.Loan_Amount) AS [TOTAL_LOAN_AMOUNT]
		FROM Borrowers B
		JOIN Financials F ON B.Borrower_Key = F.Borrower_Key
		GROUP BY B.State
),
TEMP_RANK AS (
	SELECT 
	*,
	DENSE_RANK() OVER(ORDER BY [TOTAL_LOAN_AMOUNT] DESC) AS [TOTAL_RANK]
	FROM TEMP_TOTAL_LOAN_AMOUNT
)
SELECT 
	B.State,
	L.Property_Usage,
	SUM(F.Loan_amount) as [TOTAL_LOAN_AMOUNT],
	T.TOTAL_RANK
	FROM TEMP_RANK T 
	JOIN Borrowers B ON B.State = T.State
	JOIN Financials F ON F.Borrower_Key = B.Borrower_Key
	JOIN Loan L ON L.Loan_Key = F.Loan_Key
	GROUP BY B.State, L.Property_Usage, T.TOTAL_RANK
	ORDER BY T.TOTAL_RANK, [TOTAL_LOAN_AMOUNT] DESC;



/*
NOTES:
	MOST LOANS ARE FOR PRIMARY RESIDENCES, FOLLOWED BY INVESTMENT PROPERTIES, WITH SECOND HOMES HAVING THE SMALLEST SHARE.
 ITS TRUE FOR MAJORITY OF THE STATES
*/


  /************************************ BUYING TREND PAGE ************************************/



  -- [TOTAL LOAN AMOUNT] AND [TOTAL MONTHLY AMOUNT] AND [TOTAL PURCHASE PRICE] BY STATE 
  -- SCATTER PLOT WITH LEGEND AND BUBBLE SIZE
  -- WE CAN SAVE IT AS A VIEW, THEN IMPORT IT TO POWER BI FOR VISUALIZATION
 -----------------------------------------------------------------------------------------------


 SELECT 
	B.State,											-- legend
	SUM(F.Monthly_Income) as [TOTAL_MONTHLY_INCOME],	-- Y-axis
	SUM(F.Purchase_Price) as [TOTAL_PURCHASE_AMOUNT],	-- X-axis
	SUM(F.Loan_Amount) as [TOTAL_LOAN_AMOUNT]			-- bubblesize
	FROM Borrowers B
	JOIN Financials F ON B.Borrower_Key = F.Borrower_Key
	GROUP BY B.STATE;


/*
NOTES:
	[TOTAL_PURCHASE_AMOUNT] AND[TOTAL_LOAN_AMOUNT] ARE DISPLAYED ON THE Y AXIS AND X AXIS RESPECTIVELY. 
	ITS NOTICABLE THAT THEY HAVE POSITIVE LINEAR RELATIONSHIP, WHEN ONE INCREASES THE OTHER INCREASES TOO.
*/