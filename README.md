# **funding_forecast**

Funding Forecasting for a Finance Company

## **Purpose and Outcome:**

•	Purpose: to identify the optimal strategy for minimizing the Cost of Funds (COF) while ensuring sufficient liquidity and profitability. 
By forecasting and strategically allocating funding across various products to determine the most cost-effective funding 

•	Outcome: achieve the lowest possible Cost of Funds (COF).

## **Dataset:**
Source: Company’s internal funding database, with 2 table name in mySQL (database name: funding_plan)

![image](https://github.com/user-attachments/assets/6fe114d6-fc12-46a0-a3a3-a026bcd3aedc)

***1.  data:***  The dataset includes historical new funding transactions from 1/1/2024 to 31/10/2024

***-	contract_no:*** Unique identifier for each contracts

***-	product:*** Category of the product 

CD: Certificate of Deposit offered by credit unions that provides a fixed interest rate and a specific maturity date

D: Deposit refers to money placed into financial institution for safekeeping

MM: A Money Market refers to a sector of the financial market where short-term borrowing and lending occurs

Offshore loan: An Offshore Loan refers to a loan that is obtained from a financial institution located outside of the borrower's home country

***-	contract_no:*** Unique identifier for each contracts

***-	valid_date:*** Effective date of the contract

***-	maturity_date:*** Scheduled completion date of the contract

***-	vnd_amount:*** Price of the contract

***-	tenor:*** Term of the contract by day

***-	interest_rate:*** Stipulated interest rate applicable to the contract, payable at maturity

***-	segment:*** The segmentation associated with the contract

***-	cus_no:*** Unique identifier for each contract holder



***2.  interest_rate:***

***-	tenor_month:*** Term of the contract by month

***-	interest_rate:*** the latest interest rate are offered




## **Analysis:**

1.	Based on the projected Ending Net Receivables (ENR) for lending in 2025 with two scenarios:
   
 - offshore loan can be rollover and new disbursment 8/2025
   
|     No.    |     Amount     |     Currency    |     Drawdown      |     Tenor (month)    |     COF (estimated)    |                         Note    |
|------------|----------------|-----------------|-------------------|----------------------|------------------------|---------------------------------|
|            |     75         |     mio USD     |     23/12/2024    |     12M              |     6.5%               |                                 |
|     1      |     75         |     mio USD     |     06/01/2025    |     12M              |     6.5%               |                                 |
|     2      |     75         |     mio USD     |     23/12/2015    |     12M              |     6.5%               |      rolled 12/2024             |
|     3      |     75         |     mio USD     |     15/08/2025    |     12M              |     6.5%               |       new disbursment           |
 
 - offshore loan can not be rollover and no new disbursment
   
|     No.    |     Amount     |     Currency    |     Drawdown      |     Tenor (month)    |     COF (estimated)    |                         Note    |
|------------|----------------|-----------------|-------------------|----------------------|------------------------|---------------------------------|
|     0      |     75         |     mio USD     |     30/12/2024    |     12M              |     6.5%               |     Can not rollover 12/2025    |
|     1      |     75         |     mio USD     |     06/01/2025    |     12M              |     6.5%               |                                 |

--> determine the reasonable Ending Balance (EB) for funding
   
--> and allocate it across products with different deposit interest rates.
   
--> forecast the new funding cash flows to achieve the lowest possible COF.
   
•	offshore loan can be rollover and new disbursment 8/2025:
![image](https://github.com/user-attachments/assets/69f0cc4a-3f6a-4fd8-9d9d-c32dd622af54)


•	offshore loan can not be rollover and no new disbursment:
![image](https://github.com/user-attachments/assets/5723a696-6f79-4ea0-bf7b-fd5bbf6165b7)

2.	After determining the total EB for the entire portfolio, forecast the EB for each product within it: 
	Loan – offshore loan is pre-planned and have large values, so they are fixed
	MM items will follow the plan to maintain 4.000 billion VND buffer, with a line of 27.000 billion VND
	CD/D items will be calculated by subtracting the fixed items, such as loans and MM

3.	To calculate the details of the CD/D items and map them to the latest quoted interest rates,
   it is necessary to allocate the maturities based on historical data (The ratio based on the past 6 months).
  	***create table name 'fp_estimate'***
  	
       TRUNCATE TABLE FP_ESTIMATE;
    COMMIT;
    
    INSERT INTO FP_ESTIMATE
    SELECT 
        c.PRODUCT,
        c.TENOR,
        c.SEGMENT,
        c.VND_AMT / 1e9 AS AMT_MIL,
        c.TOTAL_AMT / 1e9 AS TOTAL_AMT,
        c.VND_AMT / c.TOTAL_AMT AS RATE
    FROM (
        SELECT 
            b.PRODUCT,
            b.TENOR,
            b.SEGMENT,
            SUM(b.VND_AMT) AS VND_AMT,
            (
                SELECT SUM(VND_AMT)
                FROM [dbo].[data]
                WHERE VALUE_DATE BETWEEN '2024-05-01' AND '2024-10-31'
                AND PRODUCT IN ('CD', 'D')
            ) AS TOTAL_AMT
        FROM (
            SELECT 
                a.VALUE_DATE,
                a.PRODUCT,
                ROUND(a.TENOR / 30, 0) AS TENOR,
                a.SEGMENT,
                a.VND_AMT
            FROM [dbo].[data] a
            WHERE a.VALUE_DATE BETWEEN '2024-05-01' AND '2024-10-31'
              AND a.PRODUCT IN ('CD', 'D')
        ) b
        GROUP BY b.PRODUCT, b.TENOR, b.SEGMENT
    ) c;
    COMMIT;


| PRODUCT | TENOR | SEGMENT | AMT_MIL       | TOTAL_AMT       | RATE                 |
|---------|-------|---------|---------------|-----------------|----------------------|
| CD      | 1     | MMFI    | 7             | 18865.583196389 | 0.000371046043322946 |
| CD      | 1     | SME     | 594.278       | 18865.583196389 | 0.0315006429334106   |
| CD      | 2     | MMFI    | 6             | 18865.583196389 | 0.000318039465705383 |
| CD      | 2     | SME     | 353.375       | 18865.583196389 | 0.0187311993656066   |
| CD      | 3     | SME     | 27.486        | 18865.583196389 | 0.00145693879239636  |
| CD      | 4     | SME     | 10            | 18865.583196389 | 0.000530065776175638 |
| CD      | 6     | CIB     | 2523.6        | 18865.583196389 | 0.133767399275684    |
| CD      | 6     | CMB     | 30            | 18865.583196389 | 0.00159019732852691  |
| CD      | 6     | MMFI    | 3736.833      | 18865.583196389 | 0.198076728458374    |
| CD      | 6     | SME     | 2275.3        | 18865.583196389 | 0.120605866053243    |
| CD      | 7     | MMFI    | 363           | 18865.583196389 | 0.0192413876751756   |
| CD      | 7     | SME     | 81.756        | 18865.583196389 | 0.00433360575970154  |
| CD      | 8     | MMFI    | 22            | 18865.583196389 | 0.0011661447075864   |
| CD      | 9     | MMFI    | 1088          | 18865.583196389 | 0.0576711564479094   |
| CD      | 9     | SME     | 78.959        | 18865.583196389 | 0.00418534636210522  |
| CD      | 10    | SME     | 2             | 18865.583196389 | 0.000106013155235128 |
| CD      | 11    | SME     | 13            | 18865.583196389 | 0.000689085509028329 |
| CD      | 12    | CIB     | 1150          | 18865.583196389 | 0.0609575642601983   |
| CD      | 12    | CMB     | 1             | 18865.583196389 | 5.30065776175638E-05 |
| CD      | 12    | MMFI    | 2642.2        | 18865.583196389 | 0.140053979381127    |
| CD      | 12    | SME     | 1229.87       | 18865.583196389 | 0.0651911996145131   |
| CD      | 13    | CIB     | 12            | 18865.583196389 | 0.000636078931410765 |
| CD      | 13    | MMFI    | 170           | 18865.583196389 | 0.00901111819498584  |
| CD      | 13    | SME     | 450.17        | 18865.583196389 | 0.0238619710460987   |
| CD      | 15    | SME     | 102           | 18865.583196389 | 0.0054066709169915   |
| D       | 1     | SME     | 94.881296879  | 18865.583196389 | 0.00502933282747182  |
| D       | 2     | SME     | 7.45          | 18865.583196389 | 0.00039489900325085  |
| D       | 3     | SME     | 1.05          | 18865.583196389 | 5.56569064984419E-05 |
| D       | 4     | SME     | 5             | 18865.583196389 | 0.000265032888087819 |
| D       | 6     | CIB     | 10.078240019  | 18865.583196389 | 0.000534213011815561 |
| D       | 6     | MMFI    | 1050          | 18865.583196389 | 0.0556569064984419   |
| D       | 6     | SME     | 262.884172602 | 18865.583196389 | 0.0139345902994569   |
| D       | 7     | MMFI    | 50            | 18865.583196389 | 0.00265032888087819  |
| D       | 9     | MMFI    | 50            | 18865.583196389 | 0.00265032888087819  |
| D       | 9     | SME     | 7.033478296   | 18865.583196389 | 0.000372820613218374 |
| D       | 10    | MMFI    | 20            | 18865.583196389 | 0.00106013155235128  |
| D       | 12    | CMB     | 100.579008593 | 18865.583196389 | 0.00533134902568247  |
| D       | 12    | MMFI    | 50            | 18865.583196389 | 0.00265032888087819  |
| D       | 12    | SME     | 4.8           | 18865.583196389 | 0.000254431572564306 |
| D       | 13    | MMFI    | 82            | 18865.583196389 | 0.00434653936464023  |
| D       | 14    | MMFI    | 100           | 18865.583196389 | 0.00530065776175638  |

4. Based on the portfolio in 2024 already includes the attrition  of CD/D for the year 2024

   Based on the EB forecast for the next year of CD/D.

   Group by tenor of table fp_estimate:

    SELECT 
        tenor
        ,round(sum(rate)*100,0) as rate
    FROM 
    	FP_ESTIMATE 
    GROUP BY 
    	tenor
    ORDER BY 
	    tenor

| tenor | rate |
|-------|------|
| 1     | 4    |
| 2     | 2    |
| 3     | 0    |
| 4     | 0    |
| 6     | 52   |
| 7     | 3    |
| 8     | 0    |
| 9     | 6    |
| 10    | 0    |
| 11    | 0    |
| 12    | 27   |
| 13    | 4    |
| 14    | 1    |
| 15    | 1    |


From there, determine the total new amount for 2025 CD and D in excel file --(check excel  file 'forecast_2025_...' in  sheet name 'ALLOCATE_CDTD')--
 ![image](https://github.com/user-attachments/assets/d59082c5-bcbf-4506-960b-0b904881aab7)

--> the total new amount for 2025 CD and D that need to be allocated to specific maturities so that the balances align with the EB of CD and D defined in item 1.


***create table name 'fp_forecast_cdd'*** the total of new amount by month for 2025 CD and TD calculate by excel file above
 
4.	After determining the total amount of new CD/D, allocate it according to the ratio based on the past 6 months of data.
***create table name 'fp_newCDD'***


      SELECT 
        d.product, 
        d.contract_no, 
        d.value_date, 
        d.due_date, 
        d.amount, 
        d.tenor_month,
        c.interest_rate AS interest_rate,
        d.segment,
        d.fee,
        c.interest_rate + d.fee as cof
    FROM 
        (SELECT 
             a.product,
             '' AS contract_no,
             b.value_date,
             b.value_date + (a.tenor * 30) AS due_date,
             ROUND(b.amount_cdd * a.rate * 1e9, -6) AS amount,
             a.tenor AS tenor_month,
             '' AS interest_rate,
             a.segment,
             CASE WHEN a.segment in ('SME','CIB','CIB') THEN 0.005 
		     ELSE 0 
		     END AS fee,
             '' AS cof
         FROM 
             fp_estimate a
         CROSS JOIN 
             fp_forecast_cdd b) d
    LEFT JOIN 
        interest_rate c
    ON 
        c.tenor_month = d.tenor_month
    ORDER BY 
         d.value_date;


| product | contract_no             | value_date              | due_date      | amount | tenor_month | interest_rate | segment | fee    | cof |
|---------|-------------------------|-------------------------|---------------|--------|-------------|---------------|---------|--------|-----|
| CD      | 2025-01-13 00:00:00.000 | 2025-02-12 00:00:00.000 | 669000000     | 1      | 0.044       | MMFI          | 0.000   | 0.044  |     |
| CD      | 2025-01-13 00:00:00.000 | 2025-02-12 00:00:00.000 | 56827000000   | 1      | 0.044       | SME           | 0.005   | 0.049  |     |
| CD      | 2025-01-13 00:00:00.000 | 2025-03-14 00:00:00.000 | 574000000     | 2      | 0.0475      | MMFI          | 0.000   | 0.0475 |     |
| CD      | 2025-01-13 00:00:00.000 | 2025-03-14 00:00:00.000 | 33791000000   | 2      | 0.0475      | SME           | 0.005   | 0.0525 |     |
| CD      | 2025-01-13 00:00:00.000 | 2025-04-13 00:00:00.000 | 2628000000    | 3      | 0.0475      | SME           | 0.005   | 0.0525 |     |
| CD      | 2025-01-13 00:00:00.000 | 2025-05-13 00:00:00.000 | 956000000     | 4      | 0.0475      | SME           | 0.005   | 0.0525 |     |
| CD      | 2025-01-13 00:00:00.000 | 2025-07-12 00:00:00.000 | 241314000000  | 6      | 0.07        | CIB           | 0.005   | 0.075  |     |
| CD      | 2025-01-13 00:00:00.000 | 2025-07-12 00:00:00.000 | 2869000000    | 6      | 0.07        | CMB           | 0.000   | 0.07   |     |
| CD      | 2025-01-13 00:00:00.000 | 2025-07-12 00:00:00.000 | 357327000000  | 6      | 0.07        | MMFI          | 0.000   | 0.07   |     |
......

This will lead to a portfolio of new CDD to be added in 2025. The data should be inputted in ***the Excel file 'forecast_2025_...' under the sheet named 'new__CDTD'***
 ![image](https://github.com/user-attachments/assets/3440808d-e5c8-4bf7-aecd-e6b863048d12)


5.	Regarding the new MM transactions
    Since MM has the characteristic of receiving overnight deposits--> it is not possible to allocate maturities to calculate new items like CD/D.
  	--> we will continue to use the existing items from 2024 and predict that they will roll over, just to ensure the end-of-month balance is maintained at 23K
![image](https://github.com/user-attachments/assets/25c3f07d-a025-42b4-a563-c6dfee38aeb6)

6.	Link all three new sheets—'new_CDD', 'new_MM', and 'new_offshore'—to the ***'2025' sheet***, which contains the entire 2024 portfolio.
   **--->This will give us the complete portfolio for 2025**
	
9.	Finally, calculate the COF for the entire portfolio at the end of each month, along with the COF for the new items using SUMIFS or SUMPRODUCT in the ***'forecast' sheet***, in order to determine which scenario is the most feasible
•	offshore loan can be rollover and new disbursment 8/2025:
![image](https://github.com/user-attachments/assets/587b0e5e-6e10-4ca7-bbd1-c6bfa0f89a34)

•	offshore loan can not be rollover and no new disbursment:
![image](https://github.com/user-attachments/assets/d1be4acb-ec73-46ae-a95e-5c573333248c)

 ## **Key insight**
Utilizing offshore loans is expected to reduce costs by an average of 8 billion VND annually. 

Additionally, securing new loans will further lower expenses by 5 billion VND, as the interest rates on foreign loans are currently more favorable than those for issuing certificates of deposit and term deposits.

 # **Advantages:**

1.	Detailed Forecasting and Planning:
   
This approach helps to build a detailed financial funding plan based on specific forecasts (ENR, interest rates, historical data, etc.). This allows the company to have a clear view of future cash flows and profitability.

3.	Flexibility:
   
The method of allocating loans and funding products (MM, CD/D) can be adjusted flexibly depending on changes in the economic environment (e.g., interest rate changes, shifts in borrowing demand, etc.).

5.	Optimization of COF (Cost of Funds):
   
By calculating and allocating funding across products with different interest rates, this method helps optimize the COF, thus reducing funding costs and improving the financial efficiency of the company.

4 Combining Historical Data and Future Projections:

This approach combines historical data analysis with future projections, leading to more accurate and grounded estimates of loans and funding in the future.

 # **Disadvantages:**
 
1.	Dependence on Historical Data:
   
Allocating loans and funding products based on historical data can be challenging if the market experiences significant changes or unforeseen factors. Past trends may not fully reflect future market conditions.

2.	Inability to Predict All Factors:

Despite using base and optimal scenarios, this approach cannot predict all factors affecting the financial market, such as unexpected interest rate fluctuations, changes in borrowing demand, or unforeseen political and economic events.

 # **In Summary:**
 
This approach can yield high effectiveness if properly executed, especially in analyzing data and accurately forecasting key factors. However, if there are unexpected changes in the market or miscalculations, the approach may face risks related to costs or failing to achieve the expected outcomes.

