-- Find Crime Scene Report 

/* 
SELECT *
	FROM crime_scene_report
	WHERE date = 20180115 and city = 'SQL City' and type = 'murder'
            
Security footage shows that there were 2 witnesses. 
The first witness lives at the last house on "Northwestern Dr". 
The second witness, named Annabel, lives somewhere on "Franklin Ave".
 */

-- Find Witness

/*
SELECT * 
	FROM person
	WHERE (name LIKE 'Annabel%'AND address_street_name = 'Franklin Ave')
		OR (address_street_name = 'Northwestern Dr' and address_number > 4900)

id	name	license_id	address_number	address_street_name	ssn
14887	Morty Schapiro	118009	4919	Northwestern Dr	111564949
16371	Annabel Miller	490173	103	Franklin Ave	318771143 
*/


-- Find Interview

/*
WITH CTE AS (SELECT * 
	FROM person
	WHERE (name LIKE 'Annabel%'AND address_street_name = 'Franklin Ave')
		OR (address_street_name = 'Northwestern Dr' and address_number > 4900))

SELECT * 
	FROM
	interview I
	JOIN CTE
		WHERE CTE.id = I.person_id
			
person_id	transcript	id	name	license_id	address_number	address_street_name	ssn
14887	I heard a gunshot and then saw a man run out. 
		He had a "Get Fit Now Gym" bag. 
		The membership number on the bag started with "48Z". 
		Only gold members have those bags. 
		The man got into a car with a plate that included "H42W".	
		14887	Morty Schapiro	118009	4919	Northwestern Dr	111564949
			
16371	I saw the murder happen, and I recognized the killer from my gym when 
		I was working out last week on January the 9th.	16371. 
		Annabel Miller	490173	103	Franklin Ave	318771143 
*/
		
-- Find Matching gym member and license plate*/
-- Potential Plates

/*
SELECT *
	FROM drivers_license
	WHERE plate_number like '%H42W%'
	

id	age	height	eye_color	hair_color	gender	plate_number	car_make	car_model
423327	30	70	brown	brown	male	0H42W2	Chevrolet	Spark LS
664760	21	71	black	black	male	4H42WR	Nissan	Altima 
*/

-- Potential Gym Memberships 

/*
WITH CTE AS (Select * 
	from get_fit_now_check_in
	WHERE check_in_date = 20180109 and membership_id LIKE '48Z%')
	
SELECT *
	FROM
	get_fit_now_member GFN
	JOIN CTE WHERE CTE.membership_id = GFN.id

id	person_id	name	membership_start_date	membership_status	membership_id	check_in_date	check_in_time	check_out_time
48Z7A	28819	Joe Germuska	20160305	gold	48Z7A	20180109	1600	1730
48Z55	67318	Jeremy Bowers	20160101	gold	48Z55	20180109	1530	1700 
*/

-- FIND KILLER

/*
WITH GYM AS (
  WITH CTE AS (Select * 
	from get_fit_now_check_in
	WHERE check_in_date = 20180109 and membership_id LIKE '48Z%')
	
SELECT *
	FROM
	get_fit_now_member GFN
	JOIN CTE WHERE CTE.membership_id = GFN.id)
	
,
	
LICENSE AS (SELECT *
	FROM drivers_license
	WHERE plate_number like '%H42W%')
	
SELECT *
	FROM person
	JOIN LICENSE
	JOIN GYM 
	where GYM.name = person.name and person.license_id = LICENSE.id 
*/
	

-- Find Mastermind 
-- Find Criminal Interview

/*
SELECT *
	FROM interview
	WHERE person_id = 67318
	
I was hired by a woman with a lot of money. 
I don't know her name but I know she's around 5'5" (65") or 5'7" (67"). 
She has red hair and she drives a Tesla Model S. 
I know that she attended the SQL Symphony Concert 3 times in December 2017. 
*/

-- Find Mastermind

/*
WITH EVENT AS (SELECT count(person_id), person_id, event_name
	FROM facebook_event_checkin
	WHERE event_name =  'SQL Symphony Concert' and (date >= 20171201 and date <= 20171231)
	GROUP BY person_id, event_name
	HAVING count(person_id) = 3)
	
,

LICENSE AS  (SELECT *
	FROM drivers_license
	WHERE car_make = 'Tesla' and car_model = 'Model S'  and hair_color = 'red' and 
	gender = 'female' and (height = 65 or height = 66)) 
	

SELECT *
	FROM person
	JOIN LICENSE
	JOIN EVENT 
	where EVENT.person_id = person.id and person.license_id = LICENSE.id
*/