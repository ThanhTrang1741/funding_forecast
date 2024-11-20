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
