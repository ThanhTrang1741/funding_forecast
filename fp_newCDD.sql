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
