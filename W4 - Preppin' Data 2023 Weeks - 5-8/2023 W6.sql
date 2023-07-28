/*
Requirements
Input the data
Reshape the data so we have 5 rows for each customer, with responses for the Mobile App and Online Interface being in separate fields on the same row
Clean the question categories so they don't have the platform in from of them
e.g. Mobile App - Ease of Use should be simply Ease of Use
Exclude the Overall Ratings, these were incorrectly calculated by the system
Calculate the Average Ratings for each platform for each customer 
Calculate the difference in Average Rating between Mobile App and Online Interface for each customer
Catergorise customers as being:
Mobile App Superfans if the difference is greater than or equal to 2 in the Mobile App's favour
Mobile App Fans if difference >= 1
Online Interface Fan
Online Interface Superfan
Neutral if difference is between 0 and 1
Calculate the Percent of Total customers in each category, rounded to 1 decimal place
Output the data
*/

WITH MOBILE AS (
SELECT
   CUSTOMER_ID,
   RIGHT(
   QUESTION,length(QUESTION)-13) AS QUESTION,
   MOBILE
FROM
    TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK06_DSB_CUSTOMER_SURVEY
        UNPIVOT 
        ("MOBILE" 
            FOR "QUESTION" 
            in (MOBILE_APP___EASE_OF_ACCESS, MOBILE_APP___EASE_OF_USE, MOBILE_APP___LIKELIHOOD_TO_RECOMMEND, MOBILE_APP___NAVIGATION)))
,
ONLINE AS (
SELECT
   CUSTOMER_ID,
   RIGHT(
   QUESTION,length(QUESTION)-19) AS QUESTION,
   ONLINE
FROM
    TIL_PLAYGROUND.PREPPIN_DATA_INPUTS.PD2023_WK06_DSB_CUSTOMER_SURVEY
        UNPIVOT 
        ("ONLINE" 
            FOR "QUESTION" 
            in (ONLINE_INTERFACE___EASE_OF_ACCESS, ONLINE_INTERFACE___EASE_OF_USE, ONLINE_INTERFACE___LIKELIHOOD_TO_RECOMMEND, ONLINE_INTERFACE___NAVIGATION)))
,
COMBINED AS (
SELECT 
    O.CUSTOMER_ID,
    AVG(O.ONLINE) AS "ONLINE",
    AVG(M.MOBILE) AS "MOBILE"
FROM    
    MOBILE M
    INNER JOIN ONLINE O ON M.CUSTOMER_ID = O.CUSTOMER_ID AND O.QUESTION = M.QUESTION
GROUP BY
    O.CUSTOMER_ID
    )


SELECT 
    CASE
        WHEN ONLINE - MOBILE >= 2 THEN 'Online Interface Superfan'
        WHEN ONLINE - MOBILE >= 1 AND ONLINE - MOBILE < 2 THEN 'Online Interface Fan'
        WHEN ONLINE - MOBILE > -1 AND ONLINE - MOBILE < 1  THEN 'Neutral'
        WHEN ONLINE - MOBILE <= -1 AND ONLINE - MOBILE > -2 THEN 'Mobile Fan'
        WHEN ONLINE - MOBILE <= -2 THEN 'Mobile Superfan'
        END AS "Preference",
    ROUND(
    COUNT(CASE
        WHEN ONLINE - MOBILE >= 2 THEN 'Online Interface Superfan'
        WHEN ONLINE - MOBILE >= 1 AND ONLINE - MOBILE < 2 THEN 'Online Interface Fan'
        WHEN ONLINE - MOBILE > -1 AND ONLINE - MOBILE < 1  THEN 'Neutral'
        WHEN ONLINE - MOBILE <= -1 AND ONLINE - MOBILE > -2 THEN 'Mobile Fan'
        WHEN ONLINE - MOBILE <= -2 THEN 'Mobile Superfan'
        END)*100 / (SELECT COUNT(*) FROM COMBINED),1) AS "% of Total"
FROM 
    COMBINED
GROUP BY "Preference"