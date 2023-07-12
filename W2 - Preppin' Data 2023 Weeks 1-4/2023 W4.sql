/*
Requirements
Input the data
We want to stack the tables on top of one another, since they have the same fields in each sheet. We can do this one of 2 ways (help):
Drag each table into the canvas and use a union step to stack them on top of one another
Use a wildcard union in the input step of one of the tables
Some of the fields aren't matching up as we'd expect, due to differences in spelling. Merge these fields together
Make a Joining Date field based on the Joining Day, Table Names and the year 2023
Now we want to reshape our data so we have a field for each demographic, for each new customer (help)
Make sure all the data types are correct for each field
Remove duplicates (help)
If a customer appears multiple times take their earliest joining date
Output the data
*/

WITH COMBINED AS (
SELECT
    *, 
    'January' AS MONTH
FROM
    TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK04_JANUARY
    UNION ALL
SELECT
    *,
    'February' AS MONTH
FROM 
    TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK04_FEBRUARY
    UNION ALL
SELECT
    *,
    'March' AS MONTH
FROM 
    TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK04_MARCH
UNION ALL
SELECT
    *,
    'April' AS MONTH
FROM 
    TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK04_APRIL
UNION ALL
SELECT
    *,
    'May' AS MONTH
FROM 
    TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK04_MAY
UNION ALL
SELECT
    *,
    'June' AS MONTH
FROM 
    TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK04_JUNE
UNION ALL
SELECT
    *,
    'July' AS MONTH
FROM 
    TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK04_JULY
UNION ALL
SELECT
    *,
    'August' AS MONTH
FROM 
    TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK04_AUGUST
UNION ALL
SELECT
    *,
    'September' AS MONTH
FROM 
    TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK04_SEPTEMBER
UNION ALL
SELECT
    *,
    'October' AS MONTH
FROM 
    TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK04_OCTOBER
UNION ALL
SELECT
    *,
    'November' AS MONTH
FROM 
    TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK04_NOVEMBER
UNION ALL
SELECT
    *,
    'December' AS MONTH
FROM 
    TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK04_DECEMBER)

SELECT 
    ID,
    DATE_FROM_PARTS(2023, CASE
            WHEN MONTH = 'JANUARY' THEN 01
            WHEN MONTH = 'FEBRUARY' THEN 02
            WHEN MONTH = 'MARCH' THEN 03
            WHEN MONTH = 'APRIL' THEN 04
            WHEN MONTH = 'MAY' THEN 05
            WHEN MONTH = 'JUNE' THEN 06
            WHEN MONTH = 'JULY' THEN 07
            WHEN MONTH = 'AUGUST' THEN 08
            WHEN MONTH = 'SEPTEMBER' THEN 09
            WHEN MONTH = 'OCTOBER' THEN 10
            WHEN MONTH = 'NOVEMBER' THEN 11
            ELSE 12 END
            , JOINING_DAY) AS "JOINING DATE",
            "'Account Type'" AS "ACCOUNT TYPE",
            date_from_parts(split_part("'Date of Birth'",'/',3),split_part("'Date of Birth'",'/',2),split_part("'Date of Birth'",'/',1)) AS "DATE OF BIRTH",
            "'Ethnicity'" AS "ETHNICITY"
FROM 
    COMBINED
       PIVOT ( min(VALUE)
            FOR DEMOGRAPHIC IN ( 'Account Type', 'Date of Birth', 'Ethnicity' ) )
    
