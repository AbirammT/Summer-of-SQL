-- 1) How many customers has Foodie-Fi ever had?

SELECT 
	COUNT(DISTINCT customer_id) AS CUSTOMERS
FROM 
	foodie_fi.subscriptions;
    
-- 2) What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value

SELECT
	DATE_TRUNC('month',start_date) AS "DATE",
    COUNT(DISTINCT customer_id) AS CUSTOMERS
FROM
	foodie_fi.subscriptions
GROUP BY
	"DATE";

-- Second solution to include month names

SELECT
	TO_CHAR(start_date,'Month') AS "DATE",
    COUNT(DISTINCT customer_id) AS "CUSTOMERS"
FROM
	foodie_fi.subscriptions
GROUP BY
	"DATE";

-- 3) What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name

SELECT
	p.plan_name AS PLAN,
    DATE_PART('year',s.start_date)::integer AS "STARTING_DATE",
    COUNT(DISTINCT s.customer_id) AS CUSTOMERS
FROM 
	foodie_fi.subscriptions s
    INNER JOIN foodie_fi.plans p
    ON s.plan_id = p.plan_id
WHERE
	DATE_PART('year',s.start_date) > 2020
GROUP BY	
	PLAN, "STARTING_DATE"

-- 4) What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

WITH total_all AS (
  SELECT COUNT(DISTINCT customer_id) AS total
  FROM 	foodie_fi.subscriptions

),
total_filtered AS (
  SELECT COUNT(DISTINCT customer_id) AS total_filtered
  FROM 	foodie_fi.subscriptions
  WHERE plan_id = 4
)
SELECT 
total_filtered AS CUSTOMERS,
ROUND(total_filtered::numeric*100 / total_all.total, 1) AS PERCENTAGE
FROM total_all, total_filtered;

-- 5) How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?

WITH RANKING AS(
SELECT
	*,
    RANK() OVER(PARTITION BY customer_id ORDER BY start_date ASC) AS rnk
FROM 
	foodie_fi.subscriptions)

SELECT 
	COUNT (DISTINCT customer_id) AS CUSTOMERS,
    ROUND(COUNT (DISTINCT customer_id)/10,0) || '%' AS CUSTOMERS
FROM 
	RANKING
WHERE
	rnk = 2 and plan_id = 4
    
-- In the previous solution I showed a method using a dynamic value for the total customers so this time I used the fact that there are 1000 customers

-- 6) What is the number and percentage of customer plans after their initial free trial?

WITH RANKING AS(
SELECT
	*,
    RANK() OVER(PARTITION BY customer_id ORDER BY start_date ASC) AS rnk
FROM 
	foodie_fi.subscriptions)

SELECT 
	P.plan_name,
	COUNT (DISTINCT R.customer_id) AS CUSTOMERS,
    ROUND(COUNT (DISTINCT R.customer_id)/10,0) || '%' AS CUSTOMERS
FROM 
	RANKING R
    INNER JOIN foodie_fi.plans P
    ON P.plan_id = R.plan_id
WHERE
	rnk = 2
GROUP BY
	P.plan_name

-- 7) What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?

WITH CLOSEST AS (
SELECT 
	customer_id::numeric,
    MAX(start_date),
    '2020-12-31'::DATE AS current_date
FROM 
	foodie_fi.subscriptions
WHERE 
	start_date <= '2020-12-31'::DATE
GROUP BY
	customer_id
ORDER BY 
	customer_id ASC)
    
SELECT
	plan_id,
    count(DISTINCT S.customer_id) AS CUSTOMERS,
	ROUND(COUNT(DISTINCT S.customer_id)/10::numeric,1) AS PERCENTAGE
FROM
	CLOSEST C
    INNER JOIN foodie_fi.subscriptions S
    ON C.customer_id = S.customer_id AND C.max = S.start_date
GROUP BY
	plan_id

-- 8) How many customers have upgraded to an annual plan in 2020?

SELECT
	COUNT(DISTINCT customer_id) AS CUSTOMERS
FROM 
	foodie_fi.subscriptions
WHERE 
	date_part('year',start_date) = 2020
    AND plan_id = 3 

-- 9) How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?

-- Check to see that everyone starts with the trial

SELECT 
	customer_id,
    min(plan_id)
FROM 
	foodie_fi.subscriptions
GROUP BY
	customer_id
HAVING
	min(plan_id) = 0
ORDER BY 
	customer_id ASC;

-- Average difference

WITH TRIAL AS 

(SELECT 
	*
FROM 
	foodie_fi.subscriptions
WHERE
 	plan_id = 0
),

ANNUAL AS
(SELECT 
	*
FROM 
	foodie_fi.subscriptions
WHERE
 	plan_id = 3
)

SELECT
    AVG(A.start_date - T.start_date)::integer AS DIFFERENCE
FROM
	TRIAL T INNER JOIN
	ANNUAL A ON T.customer_id = A.customer_id

-- 10) Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)

WITH TRIAL AS 

(SELECT 
	*
FROM 
	foodie_fi.subscriptions
WHERE
 	plan_id = 0
),

ANNUAL AS
(SELECT 
	*
FROM 
	foodie_fi.subscriptions
WHERE
 	plan_id = 3
)

SELECT
    FLOOR((A.start_date - T.start_date) / 30 ) * 30 || '-' || (FLOOR((A.start_date - T.start_date) / 30) * 30 + 30) AS bucket_name,
    COUNT(FLOOR((A.start_date - T.start_date) / 30 ) * 30 || '-' || (FLOOR((A.start_date - T.start_date) / 30) * 30 + 30)) AS CUSTOMERS
FROM
	TRIAL T INNER JOIN
	ANNUAL A ON T.customer_id = A.customer_id
GROUP BY
	bucket_name
ORDER BY
	bucket_name;

-- 11) How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

WITH MONTHLY AS (
SELECT 
	*,
    RANK () OVER (PARTITION BY customer_id ORDER BY start_date)
FROM 
	foodie_fi.subscriptions
WHERE
	plan_id = 2 or plan_id = 1
ORDER BY
	customer_id,
    start_date)

SELECT 
	count(customer_id) as DOWNGRADED
FROM
	MONTHLY
WHERE 
	plan_id = 1 and rank = 2 and date_part('year', start_date) = 2020;