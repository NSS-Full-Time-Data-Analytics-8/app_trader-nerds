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

-----------APPLE----------

SELECT * 
FROM app_store_apps
WHERE rating IS NOT NULL
ORDER BY review_count DESC;

-------------------------
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
ORDER BY p_review DESC

------------------------

SELECT play_store_apps.name, 
((app_store_apps.rating::numeric*app_store_apps.review_count::numeric+play_store_apps.rating::numeric*play_store_apps.review_count::numeric)/(app_store_apps.review_count::numeric + play_store_apps.review_count::numeric)) AS weighted_review_avg, app_store_apps.price
FROM app_store_apps
INNER JOIN play_store_apps
USING(name)
ORDER BY weighted_review_avg DESC;

------------------------
SELECT DISTINCT play_store_apps.name, 
((app_store_apps.rating::numeric*app_store_apps.review_count::numeric+play_store_apps.rating::numeric*play_store_apps.review_count::numeric)/(app_store_apps.review_count::numeric + play_store_apps.review_count::numeric)) AS weighted_review_avg, app_store_apps.price
FROM app_store_apps
INNER JOIN play_store_apps
USING(name)
ORDER BY weighted_review_avg DESC;

---------------------------------------

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

---------------------------------------

WITH weighted_avg_price AS	(
SELECT p.name, ((app_store_apps.price::numeric*app_store_apps.review_count::numeric+p.price::money::numeric*p.review_count::numeric)/(app_store_apps.review_count::numeric + p.review_count::numeric)) AS weighted_price_avg
FROM app_store_apps
INNER JOIN play_store_apps AS p
USING(name)
ORDER BY weighted_price_avg DESC
						)
						
--------------------------------------
SELECT play_store_apps.name, ((app_store_apps.rating::numeric*app_store_apps.review_count::numeric+play_store_apps.rating::numeric*play_store_apps.review_count::numeric)/(app_store_apps.review_count::numeric + play_store_apps.review_count::numeric)) AS weighted_review_avg, app_store_apps.price
FROM app_store_apps
INNER JOIN play_store_apps
USING(name)
ORDER BY weighted_review_avg DESC;

-------------------------------------

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
