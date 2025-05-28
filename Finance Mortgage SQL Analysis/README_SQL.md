# Finance Mortgage Loan Analysis: SQL Analysis

## Introduction

This README provides comprehensive details on the database/ tables creation, required data manipulation and SQL query creation that can act as the source of the visuals in the power bi file included. 
In a nutshell,
I have an power bi file named - Loan_Mortgage_Analysis.pbix 
In the sql files :
1) 'Finance_Mortgage_database_script.sql'
   Creates all the tables and fills it with data
2) 'Financial Data Preprocessing.sql'
   Does relevant data type changes, addition of columns and views to facilitate creation of proper data visualization queries.
3) 'Financial Data Visualization.sql'
   SQL implemenatation to create queries corresponding to each visual included in the powerbi file.

## 1. Detail of the Data Set

Create a database in SSMS of the name 'Finance Mortgage Loan Analysis'.
Execute the script provided, 'Finance_Mortgage_database_script' sql file. This will create all the tables and fill it 
with data.

The dataset is organized as tables such that each provides specific information:

### a. Borrower Table

- **Description**: Contains details about the borrowers, including personal information, contact details, and demographics.
- **Number of Rows**: 2000
- **Number of Columns**: 15
  - Key columns: Borrower Key, SSN (Social Security Number), First Name, Last Name, Email, Phone, Cell Phone, Marital Status, DOB (Date of Birth), Address, State, Zip, Sex, Ethnicity, Race

### b. Loan Table

- **Description**: Includes details about the loan type, purpose, co-borrower information, and other loan-specific details.
- **Number of Rows**: 2000
- **Number of Columns**: 9
  - Key columns: Loan Key, Loan ID, Property ID, Property Usage, Purpose of Loan, Credit Card Authorization, Co-Borrower SSN, Rent or Own, Loan Date

### c. Property Table

- **Description**: Contains information about properties related to the mortgage loans, including location and real estate agent details.
- **Number of Rows**: 2000
- **Number of Columns**: 8
  - Key columns: Property Key, Property ID, Property City, Property State, Property Zip, Real Estate Agent Name, Real Estate Agent Phone, Real Estate Agent Email

### d. Financials Table

- **Description**: Provides financial information such as income, assets, and liabilities related to the borrowers and their mortgage applications.
- **Number of Rows**: 3000
- **Number of Columns**: 16
  - Key columns: Financial Key, Borrower Key, Property Key, Loan Key, Years at Address, Loan Amount, Purchase Price, Number of Units, Monthly Income, Bonuses, Commission, Other Income, Checking, Savings, Retirement Fund, Mutual Fund

## 2. Data Preprocessing

### a. Adding/ altering tables and columns

Execute the script provided, 'Financial Data Preprocessing' 
The dataset is transformed to ensure relevance and consistency for analysis. Essential transformations were made, including:

- **Borrower Table**: 
Changed column 'zip' to varchar(6).
Created primary key - 'PK_Borrowers_Borrower_key'

- **Loan Table**: 
Added columns - Year_Ext, Month_Ext, Quater_Ext, Day_Ext and MonthName_Ext
Created primary key - 'PK_Loan_Loan_key'

- **Property Table**: 
Inserted a merged column (city and state), and renamed column to 'City_State'.
Added columns - Year_Ext, Month_Ext, Quater_Ext, Day_Ext and MonthName_Ext
Created primary key - 'PK_Property_Property_key'

To create a relationship between property and loan :
Convert the property_id column to not nullable.
Setting unique constriant on property_id
Create a foreign key in Loan table - 'FK_Property_Property_ID' to property table (This could be done only after property_id was made not nullable and unique)

- **Financial Table**:
Removed null values (1000 rows) through loan key column.
Convert the financial_key column to not nullable.
Created primary key - 'PK_Financial_Financial_key'
Created foreign keys - 'FK_Borrower_Key' to Borrowers table, 'FK_Property_Key' to Property table, 'FK_Loan_Key' to Loan table.


-**View**:
Created a view - 'vw_Borrowers_With_Age' that will have extra columns 'Age' and 'Age Breakdown'


## 3. Visualization and Analysis

### Overview Dashboard 

Provides an overview of mortgage lending in the US for 2019, including:

- **Question 1**: Top 5 states with the highest total loan amounts in 2019.
  - **Answer**: California, New York, Pennsylvania, Michigan, and Kentucky had the highest loan amounts. California alone accounted for 6.95% of the total loan amount.

- **Question 2**: Age group with the highest total loan amount.
  - **Answer**: Individuals over 55 years old had the highest total loan amount, totaling nearly 49.01% of the total loan amount.


### Loan Approval Dashboard

Displays loan amount by state and age breakdown, percentage of loan amount by marital status and gender, and the number of credit approvals by loan purpose.

- **Question 1**: Effect of loan purpose on credit approval.
  - **Answer**: Loans with the 'Purchase' purpose had the highest number of credit approvals, particularly for primary residence purchases.

- **Question 2**: Which Age group has highest loan amount across states.
  - **Answer**: CA, NY and PA are the top 3 states that has max loan amount. In all of these state 55+ community 
	takes up more loans and outwits other communities with considerable margin

- **QUESTION 3** Individuals belonging to which marital status take maximum loan
  - **Answer**: Married couples account for 56% of the total loan amount, 
  followed by single individuals at around 15%, marking a significant difference

- **QUESTION 4** Which gender has the highest loan amount 
  - **Answer**: Female customers make up almost double the % total loan amount of males 

- **QUESTION 5** For what purpose have people taken the highest amount of loan. Is it rent or own? 
  - **Answer**: Total loan amount is highest for purchasing and constructing homes. people take loans for purchasing and 
	constructing their own homes. overall, loans are taken for 'own' properties irrespective of the purpose of the loan.


### Borrower Dashboard 

Analyzes trends and relationships between loan amounts and monthly income, categorized by age, marital status and gender.

- **Question 1**: Relationship between loan amounts and monthly income by year and month.
  - **Answer**: Higher monthly income correlates with higher loan approvals, indicating the importance of financial stability in securing larger loans.

- **Question 2**: What is the total loan amount for 2019?
  - **Answer**: 1.06 B

- **Question 3**: What is the total monthly income for 2019?
  - **Answer**: 19.61 M

- **Question 4**: What is the total savings for 2019?
  - **Answer**: 2.09 M


### Property Dashboard 

Shows loan details based on property usage in various states.


- **Question 1**: Distribution of loans by property usage.
  - **Answer**: Most loans are for primary residences, followed by investment properties, with second homes having the smallest share.


### Buying Trend Dashboard

Displays the relationship between purchase price and monthly income over 2019 and features 

- **Question 1**: Influence of total monthly income on home purchases.
  - **Answer**: Higher monthly income leads to higher home purchase investments, underscoring the importance of financial capability in purchasing decisions.




### Vocabulary:

- **Property:**

Property Usage: 
* Investment
* Primary Residence
* Second Home

- **Purpose Of Loan:**

1. Cash-Out Finance
A cash-out refinance allows a homeowner to replace their existing mortgage with a new one that has a higher loan amount. The difference between the old mortgage and the new mortgage is taken as cash by the homeowner.

Example:
Home Value: $300,000
Existing Mortgage Balance: $200,000
New Loan Amount: $250,000
Cash Received: $50,000
?? Used for: Home renovations, debt consolidation, or other expenses.
?? Higher interest rates than traditional refinancing.

2. Construction Loan
A construction loan is a short-term loan used to finance the building of a new home or property.
?? Funds are disbursed in stages (called "draws") based on the construction progress.
?? Higher interest rates compared to traditional mortgages.
?? Once the construction is complete, borrowers may convert it into a permanent mortgage or pay it off in full.

3. Construction-Perm (Construction-to-Permanent Loan)
A construction-to-permanent loan combines a construction loan and a permanent mortgage into one single loan.
How it Works:
1?? The loan starts as a construction loan while the home is being built.
2?? Once construction is complete, it automatically converts into a permanent mortgage.
?? Advantage: No need for two separate loans (avoids extra closing costs and paperwork).
?? Commonly used for custom-built homes.

4. No Cash-Out Refinance
A no cash-out refinance (or rate-and-term refinance) replaces the existing mortgage with a new one without taking additional cash.
?? The main goal is to reduce the interest rate or change the loan term (e.g., from 30 years to 15 years).
?? Unlike cash-out refinance, you do not receive any extra money beyond what is needed to pay off the existing loan.
Example:
Old Loan: $200,000 at 5% interest
New Loan: $200,000 at 3.5% interest
No extra cash is taken

5. Purchase Loan
A purchase loan is a mortgage loan used to buy a home (instead of refinancing an existing one).
?? Can be conventional, FHA, VA, or USDA loans.
?? Requires a down payment (usually 3% to 20% of the home price).
?? Interest rates and terms depend on the borrower's credit, income, and loan type.
Example:
Home Price: $300,000
Down Payment: $60,000 (20%)
Loan Amount: $240,000


