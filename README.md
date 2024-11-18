# funding_forecast
Funding Forecasting for a Finance Company
Purpose and Outcome:
•	Purpose: to identify the optimal strategy for minimizing the Cost of Funds (COF) while ensuring sufficient liquidity and profitability. 
By forecasting and strategically allocating funding across various products to determine the most cost-effective funding 
•	Outcome: achieve the lowest possible Cost of Funds (COF).
Dataset:
•	Source: Company’s internal funding database, with 2 table name in mySQL:
1.  data:  The dataset includes historical funding data in 2024.
-	contract_no: Unique identifier for each contracts
-	product: Category of the product 
CD: Certificate of Deposit offered by credit unions that provides a fixed interest rate and a specific maturity date
D: Deposit refers to money placed into financial institution for safekeeping
MM: A Money Market refers to a sector of the financial market where short-term borrowing and lending occurs
Offshore loan: An Offshore Loan refers to a loan that is obtained from a financial institution located outside of the borrower's home country
-	contract_no: Unique identifier for each contracts
-	valid_date: Effective date of the contract
-	maturity_date: Scheduled completion date of the contract
-	vnd_amount: Price of the contract
-	tenor: Term of the contract by day
-	interest_rate: Stipulated interest rate applicable to the contract, payable at maturity
-	Segment: The segmentation associated with the contract.
-	Cus_no: Unique identifier for each contract holder

2.  interest_rate.
o	tenor_month: Term of the contract by month
o	interest_rate: the latest interest rate are offered
