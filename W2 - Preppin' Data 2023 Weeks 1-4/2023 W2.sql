/*
Requirements
Input the data
In the Transactions table, there is a Sort Code field which contains dashes. We need to remove these so just have a 6 digit string (hint)
Use the SWIFT Bank Code lookup table to bring in additional information about the SWIFT code and Check Digits of the receiving bank account (hint)
Add a field for the Country Code (hint)
Hint: all these transactions take place in the UK so the Country Code should be GB
Create the IBAN as above (hint)
Hint: watch out for trying to combine sting fields with numeric fields - check data types
Remove unnecessary fields (hint)
Output the dataS
*/

ELECT
    TC.TRANSACTION_ID,
    'GB' || SC.CHECK_DIGITS || SC.SWIFT_CODE || replace(TC.SORT_CODE,'-','') || TC.ACCOUNT_NUMBER AS IBAN
FROM TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK02_SWIFT_CODES SC
    INNER JOIN TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK02_TRANSACTIONS TC
    WHERE SC.BANK = TC.BANK