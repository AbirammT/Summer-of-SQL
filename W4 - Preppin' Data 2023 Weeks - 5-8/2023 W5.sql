/*
Requirements
Input data
Create the bank code by splitting out off the letters from the Transaction code, call this field 'Bank' DONE
Change transaction date to the just be the month of the transaction
Total up the transaction values so you have one row for each bank and month combination
Rank each bank for their value of transactions each month against the other banks. 1st is the highest value of transactions, 3rd the lowest. 
Without losing all of the other data fields, find:
The average rank a bank has across all of the months, call this field 'Avg Rank per Bank'
The average transaction value per rank, call this field 'Avg Transaction Value per Rank'
Output the data
*/

-- General transformations


WITH RANKING AS (
SELECT 
    SPLIT_PART(TRANSACTION_CODE,'-',1) AS "BANK",
    MONTHNAME(
    DATE_FROM_PARTS(
    SPLIT_PART(LEFT(TRANSACTION_DATE,10),'/',3),
    SPLIT_PART(LEFT(TRANSACTION_DATE,10),'/',2),
    SPLIT_PART(LEFT(TRANSACTION_DATE,10),'/',1)
    )) AS "MONTH",
    SUM(VALUE) AS "VALUE",
    RANK() OVER (PARTITION BY "MONTH" ORDER BY SUM(VALUE) DESC) AS "RANK"
FROM
    TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK01
GROUP BY
    "BANK",
    "MONTH")
,

AV_BANK AS (
SELECT
    "BANK",
    AVG("RANK") AS "AVG RANK per BANK"
FROM 
    RANKING
GROUP BY
    BANK
)
,
AV_RANK AS (
SELECT
    "RANK",
    AVG("VALUE") AS "AVG VALUE per RANK"
FROM 
    RANKING
GROUP BY
    "RANK"
)

SELECT 
    R.BANK,
    R.MONTH,
    R.VALUE,
    AR."AVG VALUE per RANK",
    AV."AVG RANK per BANK"
FROM
    RANKING R
    INNER JOIN AV_RANK AR ON R.RANK = AR.RANK
    INNER JOIN AV_BANK AV ON R.BANK = AV.BANK
    