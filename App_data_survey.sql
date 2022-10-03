--# OF APPS (DISTINCT NAMES)
--328 apps in both stores
--6867 apps in app store but not play store
--9331 apps in play store but not app store
--16,526 total apps across both stores

--APPS W/MULTIPLE RECORDS
--app store: 2 apps have multiple records
--play store: 798 apps have multiple records

--PRICES
--Both stores: all apps have price values (no nulls)
--app store: 0 apps have multiple prices
--play store: 2 apps have 2 different prices (a free version and a paid version) 
--both stores: 30 apps have different prices in app store vs play store

--GENRES & CATEGORIES
--app store: 23 genres
--play store: 33 categories and 119 genres
--            most (89) genres fit within one category,
--            but 30 genres are associated with two categories

--STAR RATINGS
--app store ratings range from 0 to 5
--play store rating range from 1 to 5
--app store: all apps have ratings
--play store: 1464 apps do not have ratings (NULL)


SELECT * FROM app_store_apps;
SELECT * FROM play_store_apps;

SELECT DISTINCT name
FROM app_store_apps INNER JOIN play_store_apps USING (name);
--328 distinct names are in both stores

SELECT DISTINCT a.name, p.name --DISTINCT a.name
FROM app_store_apps a LEFT JOIN play_store_apps p USING (name)
WHERE p.name IS NULL;
--6867 apps in app store but not play store
--9331 apps in play store but not app store

SELECT DISTINCT a.name, p.name
FROM app_store_apps a FULL JOIN play_store_apps p USING (name);
--16,526 apps across both stores
-----------------------------
--DUPLICATE NAMES

SELECT name, COUNT (*)
FROM app_store_apps
GROUP BY name 
ORDER BY COUNT(*) DESC;
-- 2 apps in app store have multiple records

SELECT *
FROM app_store_apps
WHERE name LIKE 'VR Roller Coaster'
      OR name LIKE 'Mannequin Challenge';
	  
SELECT name, COUNT (*)
FROM play_store_apps
GROUP BY name 
ORDER BY COUNT(*) DESC;
--798 apps in play store have multiple records

WITH mutirownames AS (SELECT name, COUNT (*)
						FROM play_store_apps
						GROUP BY name 
						HAVING COUNT(*) > 1)
SELECT *
FROM play_store_apps INNER JOIN mutirownames USING (name)
ORDER BY name;

SELECT * FROM play_store_apps WHERE name like 'Solitaire';

SELECT *
FROM play_store_apps
WHERE name LIKE 'CBS Sports App - Scores, News, Stats & Watch Live'
      OR name LIKE 'ROBLOX'; -- these are just 2 examples out of 798

---------------------------
--PRICES

SELECT DISTINCT(name) FROM app_store_apps WHERE price is NULL;
--app store: all apps have price values
SELECT DISTINCT (name) FROM play_store_apps WHERE price is NULL;
--play store: all apps have price values

SELECT name, COUNT(DISTINCT price) AS prices
FROM play_store_apps
GROUP BY name 
ORDER BY prices DESC;
--In play store, 2 apps have 2 different prices (a free version and a paid version)

SELECT * FROM play_store_apps
WHERE name LIKE 'Cardiac diagnosis (heart rate, arrhythmia)'
      OR name LIKE 'Calculator'
ORDER BY name;

SELECT COUNT(DISTINCT name) --, a.price, p.price::money::numeric
FROM app_store_apps a INNER JOIN play_store_apps p USING (name)
WHERE a.price <> p.price::money::numeric;
-- 30 apps have different prices in app store vs play store
SELECT name, a.price, p.price::money::numeric
FROM app_store_apps a INNER JOIN play_store_apps p USING (name)
WHERE a.price <> p.price::money::numeric;

--------------------------
--Category, Genre

SELECT DISTINCT primary_genre
FROM app_store_apps;
-- 23 Genres in app store
SELECT DISTINCT category
FROM play_store_apps;
--33 categories in play store
SELECT DISTINCT genres
FROM play_store_apps;
--119 genres in play store
SELECT genres, count(distinct category)
FROM play_store_apps
GROUP BY genres
ORDER BY count(distinct category)DESC;
-- 89 genres appear in only 1 category; 30 genres appear in 2 different categories.

-------------------------
--Star Ratings

SELECT MAX(rating), MIN(rating) FROM app_store_apps;
--app store ratings range from 0 to 5
select MAX(rating), MIN(rating) FROM play_store_apps;
--play store rating range from 1 to 5
SELECT DISTINCT(name) FROM app_store_apps WHERE rating is NULL;
--app store: all apps have ratings
SELECT DISTINCT (name) FROM play_store_apps WHERE rating is NULL;
--play store: 1464 apps do not have ratings

-------------------------
--------TEMP: Analysis of category = FAMILY
SELECT name, category, count(*)
FROM play_store_apps
WHERE name IN (SELECT DISTINCT name
				FROM play_store_apps
				WHERE category LIKE 'FAMILY')
	  AND category NOT LIKE 'FAMILY'
GROUP BY name, category
ORDER BY count(*);

SELECT name, COUNT(DISTINCT category), count(*)
FROM play_store_apps
WHERE category NOT LIKE 'FAMILY'
GROUP BY name
ORDER BY COUNT(DISTINCT category) DESC;

select * from play_store_apps 
where name in ('Call Blocker','Calculator','Ruler','8 Ball Pool')
ORDER BY NAME;

SELECT distinct name
FROM play_store_apps
WHERE category LIKE 'FAMILY';

SELECT name, review_count, count(*)
from play_store_apps
group by name, review_count
order by count(*) desc;

select * from play_store_apps 
where name in ('Skyscanner','Nick','Google Keep','Fashion in Vogue')
ORDER BY NAME;

select name, review_count, category, count(*)
from play_store_apps
group by name, review_count, category
order by count(*) desc;

select name, review_count, count(*)
from (SELECT DISTINCT * FROM play_store_apps) AS distinct_p_s_a
group by name, review_count
order by count(*) desc;
--6 apps have two rows for the same name and review count.

select * from app_store_apps 
where name in ('YouTube Gaming',
			   'Learn C++',
			   --'ROBLOX',
			   --'Dog Run - Pet Dog Simulator',
			   'Fuzzy Numbers: Pre-K Number Foundation',
			   'Candy Bomb')
ORDER BY NAME, review_count DESC;

select * from app_store_apps
where name ilike 'Mannequin Challenge';