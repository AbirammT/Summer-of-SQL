/*
Requirements
Input the data
For the transactions file:
Filter the transactions to just look at DSB (help)
These will be transactions that contain DSB in the Transaction Code field
Rename the values in the Online or In-person field, Online of the 1 values and In-Person for the 2 values
Change the date to be the quarter (help)
Sum the transaction values for each quarter and for each Type of Transaction (Online or In-Person) (help)
For the targets file:
Pivot the quarterly targets so we have a row for each Type of Transaction and each Quarter (help)
 Rename the fields
Remove the 'Q' from the quarter field and make the data type numeric (help)
Join the two datasets together (help)
You may need more than one join clause!
Remove unnecessary fields
Calculate the Variance to Target for each row (help)
Output the data
*/

-- Transform Transactions

WITH TRANSACTIONS AS (
SELECT
    SUM(VALUE) as VALUE,
     CASE
        WHEN ONLINE_OR_IN_PERSON = 1 THEN 'Online'
        ELSE 'In-Person'
        END
        AS "TYPE",
    'Q' || to_char(
    quarter(date_from_parts(split_part(left(transaction_date,10), '/', 3),
    split_part(left(transaction_date,10), '/', 2),
    split_part(left(transaction_date,10), '/', 1))))
    AS "QUARTER"
FROM
    TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK01
WHERE 
    LEFT(transaction_code,3) = 'DSB'
GROUP BY
    TYPE, QUARTER
    )
    ,
    

-- Transform Targets

TARGETS AS (
SELECT   
    *
FROM
    TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK03_TARGETS
        unpivot(TARGETS for QUARTER in (Q1,Q2,Q3,Q4) )
        )

SELECT
    TYPE,
    TR.QUARTER,
    VALUE,
    TARGETS AS "QUARTERLY TARGETS",
    VALUE - TARGETS AS "VARIANCE TO TARGET"
FROM
    TRANSACTIONS TR
    INNER JOIN TARGETS TA
    WHERE TR.QUARTER = TA.QUARTER AND TR.TYPE = TA.ONLINE_OR_IN_PERSON
