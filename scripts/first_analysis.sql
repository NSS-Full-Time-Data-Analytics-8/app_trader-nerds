SELECT *
FROM play_store_apps
WHERE rating IS NOT NULL 
ORDER BY review_count DESC;
--

SELECT COUNT(*)
FROM play_store_apps

SELECT DISTINCT category, COUNT(install_count)
FROM play_store_apps
GROUP BY category, install_count
ORDER BY COUNT(install_count) DESC
--
SELECT name, category, review_count 
FROM play_store_apps
WHERE rating IS NOT NULL
GROUP BY name, category, review_count
ORDER BY review_count DESC;

SELECT name, review_count, rating, category, price
FROM play_store_apps
WHERE rating IS NOT NULL AND rating > 4 
GROUP BY name, review_count, rating, category, price 
ORDER BY review_count DESC;

-----------app store------

SELECT * 
FROM app_store_apps
WHERE rating IS NOT NULL
ORDER BY review_count DESC;

---------------COMPARE SHARED APP and RANKINGS FROM BOTH STORES
SELECT DISTINCT name, 
		        apple.review_count AS apple_review, 
			 	apple.rating AS a_rating,
			 	primary_genre,
			 	play.rating AS p_rating,
			 	play.review_count AS p_review
FROM app_store_apps AS apple
INNER JOIN play_store_apps AS play
USING(name)
WHERE apple.rating IS NOT NULL AND play.rating IS NOT NULL
GROUP BY name, apple.review_count, apple.rating, primary_genre, play.rating, play.review_count 
ORDER BY p_rating DESC;

--------FIND TOP RANKING GAMES in APP STORE

SELECT DISTINCT  name, primary_genre, p.category, AVG(a.rating), a.review_count::numeric
FROM app_store_apps AS a
LEFT JOIN play_store_apps AS p
USING(name)
WHERE a.rating > 4
GROUP BY name, primary_genre, a.review_count, p.category
ORDER BY review_count DESC
LIMIT 10;


------------------------

SELECT play_store_apps.name, 
((app_store_apps.rating::numeric*app_store_apps.review_count::numeric+play_store_apps.rating::numeric*play_store_apps.review_count::numeric)/(app_store_apps.review_count::numeric + play_store_apps.review_count::numeric)) AS weighted_review_avg, app_store_apps.price
FROM app_store_apps
INNER JOIN play_store_apps
USING(name)
ORDER BY weighted_review_avg DESC;

-------------WEIGHTED AVG of PLAYSTORE review score-----------
SELECT DISTINCT play_store_apps.name, 
((app_store_apps.rating::numeric*app_store_apps.review_count::numeric+play_store_apps.rating::numeric*play_store_apps.review_count::numeric)/(app_store_apps.review_count::numeric + play_store_apps.review_count::numeric)) AS weighted_review_avg, app_store_apps.price
FROM app_store_apps
INNER JOIN play_store_apps
USING(name)
ORDER BY weighted_review_avg DESC;

----------HIGHEST REVIEWED FROM ALL STORE WHERE PRICE IS 0 --------------

SELECT DISTINCT name, category, 
primary_genre, 
app.review_count AS appl_review, 
play.review_count AS play_review, 
app.price AS appl_price, 
play.price AS play_price
FROM app_store_apps AS app
INNER JOIN play_store_apps AS play
USING(name)
WHERE app.price::money = '0' AND play.price::money = '0'
ORDER BY play.review_count DESC;


						
----------POTENTIAL PROFIT DATA FROM weighted averages -------------------


WITH app_weighted_avg AS
	(SELECT DISTINCT name, 
	       ((a.price * a.review_count::numeric) + (p.price::money::numeric * p.review_count)) 
	          / (a.review_count::numeric + p.review_count) AS weighted_avg_price,
		   (((a.rating*a.review_count::numeric) + (p.rating*p.review_count))
			 / (a.review_count::numeric + p.review_count)) AS weighted_avg_review
	FROM app_store_apps a INNER JOIN play_store_apps p USING(name))

SELECT DISTINCT p.name, primary_genre,
	   ROUND(wa.weighted_avg_price, 2) AS weighted_avg_price,
	   ROUND(CASE WHEN wa.weighted_avg_price <= 2.5 THEN 25000
            ELSE wa.weighted_avg_price * 10000 END, 2 )AS rights_purchase_cost,
       a.rating, 
	   p.rating,
	   ROUND(wa.weighted_avg_review,2) AS weighted_avg_review, 
	   
	   12 + (6 * ROUND((wa.weighted_avg_review / 0.25),0)) as lifespan_months,
	   5000 * (6 * ROUND((wa.weighted_avg_review / 0.25),0)) as total_in_app_revenue,
	   1000 * (6 * ROUND((wa.weighted_avg_review / 0.25),0)) as total_marketing_expense,
	   ROUND(((5000 * (6 * ROUND((wa.weighted_avg_review / 0.25),0))) --monthly revenue
	   - (1000 * (6 * ROUND((wa.weighted_avg_review / 0.25),0))) --minus monthly marketing expense
	   - CASE WHEN wa.weighted_avg_price <= 2.5 THEN 25000    --minus rights purchase cost
              ELSE wa.weighted_avg_price * 10000 END), 2)  
	   AS total_profit
FROM app_store_apps a  JOIN play_store_apps p USING(name)
					   JOIN app_weighted_avg wa USING(name)
ORDER BY total_profit DESC;

-----------------------------------------

WITH app_weighted_avg AS
	(SELECT name, 
	       ((a.price * a.review_count::numeric) + (p.price::money::numeric * p.review_count)) 
	          / (a.review_count::numeric + p.review_count) AS weighted_avg_price,
		   (((a.rating*a.review_count::numeric) + (p.rating*p.review_count))
			 / (a.review_count::numeric + p.review_count)) AS weighted_avg_review
	FROM app_store_apps a INNER JOIN play_store_apps p USING(name))
SELECT DISTINCT p.name,
	   ROUND(wa.weighted_avg_price, 2) AS weighted_avg_price,
	   ROUND(CASE WHEN wa.weighted_avg_price <= 2.5 THEN 25000
            ELSE wa.weighted_avg_price * 10000 END, 2 )AS rights_purchase_cost,
       a.rating, 
	   p.rating,
	   ROUND(wa.weighted_avg_review,2) AS weighted_avg_review, 
	   12 + 6 * ROUND(wa.weighted_avg_review*4,0) as lifespan_months,
	   5000 * (12 + 6 * ROUND(wa.weighted_avg_review*4,0)) as total_in_app_revenue,
	   1000 * (12 + 6 * ROUND(wa.weighted_avg_review*4,0)) as total_marketing_expense,
	   ROUND((5000 * (12 + 6 * ROUND(wa.weighted_avg_review*4,0))) --monthly revenue
	   - 1000 * (12 + 6 * ROUND(wa.weighted_avg_review*4,0)) --minus monthly marketing expense
	   - CASE WHEN wa.weighted_avg_price <= 2.5 THEN 25000    --minus rights purchase cost
              ELSE wa.weighted_avg_price * 10000 END, 2)  
	   AS total_profit
FROM app_store_apps a INNER JOIN play_store_apps p USING(name)
					  INNER JOIN app_weighted_avg wa USING(name)
ORDER BY total_profit DESC;

------APPS ONLY IN PLAYSTORE-----

SELECT DISTINCT a.name,
	   a.price,
	   ROUND(CASE WHEN a.price <= 2.5 THEN 25000
             ELSE a.price * 10000 END, 2 )AS rights_purchase_cost,
       a.rating, 
	  -- 12 + (6 * ROUND((a.rating / 0.25),0)) as lifespan_months,
	  -- 5000 * (12 + (6 * ROUND((a.rating / 0.25),0))) as total_in_app_revenue,
	  -- 1000 * (12 + (6 * ROUND((a.rating / 0.25),0))) as total_marketing_expense,
	   ROUND(((5000 * (12 + (6 * ROUND((a.rating / 0.25),0)))) --monthly revenue
	   - (1000 * (12 + (6 * ROUND((a.rating / 0.25),0)))) --minus monthly marketing expense
	   - CASE WHEN a.price <= 2.5 THEN 25000    --minus rights purchase cost
              ELSE a.price * 10000 END), 2)  
	   AS total_profit
FROM app_store_apps a FULL JOIN play_store_apps p USING(name)
WHERE p.name IS NULL
ORDER BY total_profit DESC;
------------------------------------
SELECT DISTINCT primary_genre, category, a.name,
	   a.price,
	   ROUND(CASE WHEN a.price <= 2.5 THEN 25000
             ELSE a.price * 10000 END, 2 )AS rights_purchase_cost,
       a.rating, 
	   12 + (6 * ROUND((a.rating / 0.25),0)) as lifespan_months,
	   5000 * (12 + (6 * ROUND((a.rating / 0.25),0))) as total_in_app_revenue,
	   1000 * (12 + (6 * ROUND((a.rating / 0.25),0))) as total_marketing_expense,
	   ROUND(((5000 * (12 + (6 * ROUND((a.rating / 0.25),0)))) --monthly revenue
	   - (1000 * (12 + (6 * ROUND((a.rating / 0.25),0)))) --minus monthly marketing expense
	   - CASE WHEN a.price <= 2.5 THEN 25000    --minus rights purchase cost
              ELSE a.price * 10000 END), 2)  
	   AS total_profit
FROM app_store_apps a FULL JOIN play_store_apps p USING(name)
WHERE p.name IS NULL AND primary_genre ILIKE 'BOOK'
ORDER BY total_profit DESC;



