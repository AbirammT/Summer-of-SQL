/*
Requirements
Input the data
For the Transaction Path table:
Make sure field naming convention matches the other tables
i.e. instead of Account_From it should be Account From
For the Account Information table:
Make sure there are no null values in the Account Holder ID
Ensure there is one row per Account Holder ID
Joint accounts will have 2 Account Holders, we want a row for each of them
For the Account Holders table:
Make sure the phone numbers start with 07
Bring the tables together
Filter out cancelled transactions 
Filter to transactions greater than £1,000 in value 
Filter out Platinum accounts
Output the data
*/

--Cleaning individual tables


WITH Transaction_Path AS (
SELECT
    TRANSACTION_ID AS "Transaction ID",
    ACCOUNT_TO AS "Account To",
    ACCOUNT_FROM AS "Account From"
FROM
    TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK07_TRANSACTION_PATH
)
,
Account_Information AS (
SELECT
    ACCOUNT_NUMBER,
    ACCOUNT_TYPE,
    VALUE AS "ACCOUNT HOLDER ID",
    BALANCE_DATE,
    BALANCE
FROM
    TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK07_ACCOUNT_INFORMATION
    LEFT JOIN LATERAL split_to_table(ACCOUNT_HOLDER_ID,', ') AH
)
,
Account_Holders AS (
SELECT
    *
FROM
    TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK07_ACCOUNT_HOLDERS
WHERE
    LEFT(CONTACT_NUMBER,1) = 7
)

SELECT
    TP."Transaction ID",
    TP."Account To",
    TD.TRANSACTION_DATE,
    TD.VALUE,
    AI.ACCOUNT_NUMBER,
    AI.ACCOUNT_TYPE,
    AI.BALANCE_DATE,
    AI.BALANCE,
    AH.NAME,
    AH.DATE_OF_BIRTH,
    AH.CONTACT_NUMBER,
    AH.FIRST_LINE_OF_ADDRESS
FROM
    Transaction_Path TP
    INNER JOIN TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK07_TRANSACTION_DETAIL TD ON TP."Transaction ID" = TD.TRANSACTION_ID
    INNER JOIN Account_Information AI ON AI."ACCOUNT_NUMBER" = TP."Account From"
    INNER JOIN Account_Holders AH ON AH."ACCOUNT_HOLDER_ID" = AI."ACCOUNT HOLDER ID"
WHERE
    AI.ACCOUNT_TYPE != 'Platinum' AND TD.CANCELLED_ = 'N' AND TD.VALUE > 1000