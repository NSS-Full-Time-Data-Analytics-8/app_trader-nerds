WITH ps_apps_max_review_count AS
	(SELECT DISTINCT *
	FROM play_store_apps AS p1
	WHERE p1.rating IS NOT NULL
		  AND p1.review_count = (SELECT MAX(review_count)
								 FROM play_store_apps AS p2
								 WHERE p2.name = p1.name)
	 ),
	app_weighted_avg AS
	(SELECT name, 
	       (a.price*a.review_count::numeric + p.price::money::numeric*p.review_count) 
	          / (a.review_count::numeric + p.review_count) AS weighted_avg_price,
		   (a.rating*a.review_count::numeric + p.rating*p.review_count)
			 / (a.review_count::numeric + p.review_count) AS weighted_avg_rating,
	       p.review_count AS ps_review_count
	FROM app_store_apps a INNER JOIN play_store_apps p USING(name))
SELECT DISTINCT p.name,
	            'both' AS store,
				ROUND(5000 * (12 + 6 * ROUND(wa.weighted_avg_rating / 0.25,0))   --total revenue
					  - 1000 * (12 + 6 * ROUND(wa.weighted_avg_rating / 0.25,0)) --minus total marketing expense
					  - CASE WHEN wa.weighted_avg_price <= 2.5 THEN 25000        --minus rights purchase expense
							 ELSE wa.weighted_avg_price * 10000 END
					  , 2) AS total_profit,										--equals total profit
				5000 * (12 + 6 * ROUND(wa.weighted_avg_rating / 0.25,0)) as total_in_app_revenue,
			    1000 * (12 + 6 * ROUND(wa.weighted_avg_rating / 0.25,0)) as total_marketing_expense,
			    ROUND(CASE WHEN wa.weighted_avg_price <= 2.5 THEN 25000
			 		  ELSE wa.weighted_avg_price * 10000 END, 2) AS rights_purchase_expense,
			    12 + 6 * ROUND(wa.weighted_avg_rating / 0.25,0) as lifespan_months,
				a.rating AS app_store_rating, 
			    p.rating AS play_store_rating,
			    ROUND(wa.weighted_avg_rating,2) AS weighted_avg_rating, 
				a.review_count::numeric AS app_store_review_count,
				p.review_count AS play_store_review_count,
			    a.price AS app_store_price,
				p.price::money::numeric AS play_store_price,
			    ROUND(wa.weighted_avg_price, 2) AS weighted_avg_price,
				a.content_rating AS app_store_content_rating,
				p.content_rating AS play_store_content_rating,
				a.primary_genre AS app_store_primary_genre,
				p.category AS play_store_category,
				p.genres AS play_store_genres
FROM app_store_apps a INNER JOIN ps_apps_max_review_count p USING(name)
					  INNER JOIN app_weighted_avg wa USING(name)
WHERE p.review_count = wa.ps_review_count
--ORDER BY total_profit DESC
ORDER BY name;


--------------------------------
----APPS IN APP STORE ONLY------

--Apps with more than one record in results:
--VR Roller Coaster
--Mannequin Challenge

SELECT DISTINCT a.name,
				'app_store' AS store,
				ROUND(2500 * (12 + 6 * ROUND(a.rating / 0.25,0))   --total revenue
				 	  - 1000 * (12 + 6 * ROUND(a.rating / 0.25,0)) --minus total marketing expense
					  - CASE WHEN a.price <= 2.5 THEN 25000        --minus rights purchase cost
							 ELSE a.price * 10000 END
					  , 2) AS total_profit,						   --equals total profit
			    2500 * (12 + 6 * ROUND(a.rating / 0.25,0)) AS total_in_app_revenue,
			    1000 * (12 + 6 * ROUND(a.rating / 0.25,0)) AS total_marketing_expense,
			    ROUND(CASE WHEN a.price <= 2.5 THEN 25000
			   		  ELSE a.price * 10000 END, 2)         AS rights_purchase_expense,
			    12 + 6 * ROUND(a.rating / 0.25,0)          AS lifespan_months,
				a.rating   AS app_store_rating,
				NULL       AS play_store_rating,
				a.rating   AS weighted_avg_rating,
				a.review_count::numeric AS app_store_review_count,
				NULL       AS play_store_review_count,
				a.price    AS app_store_price,
				NULL       AS play_store_price,
				a.price    AS weighted_avg_price,
				a.content_rating AS app_store_content_rating,
				NULL	   AS play_store_content_rating,
				a.primary_genre AS app_store_primary_genre,
				NULL       AS play_store_category,
				NULL       AS play_store_genres
FROM app_store_apps a LEFT JOIN play_store_apps p USING(name)
WHERE p.name IS NULL
ORDER BY total_profit DESC;

---------------------------------
----APPS IN PLAY STORE ONLY------

--Apps with more than one record in results:
--'YouTube Gaming',
--'Learn C++',
--'Fuzzy Numbers: Pre-K Number Foundation',
--'Candy Bomb'

WITH ps_apps_max_review_count AS
	(SELECT DISTINCT *
	FROM play_store_apps AS p1
	WHERE p1.rating IS NOT NULL
		  AND p1.review_count = (SELECT MAX(review_count)
								 FROM play_store_apps AS p2
								 WHERE p2.name = p1.name)
	 )
SELECT DISTINCT p.name,
				'play_store' AS store,
				ROUND(2500 * (12 + 6 * ROUND(p.rating / 0.25,0))   --total revenue
				 	  - 1000 * (12 + 6 * ROUND(p.rating / 0.25,0)) --minus total marketing expense
					  - CASE WHEN p.price::money::numeric <= 2.5 THEN 25000 --minus rights purchase cost
							 ELSE p.price::money::numeric * 10000 END
					  , 2) AS total_profit,						   --equals total profit
			    2500 * (12 + 6 * ROUND(p.rating / 0.25,0)) AS total_in_app_revenue,
			    1000 * (12 + 6 * ROUND(p.rating / 0.25,0)) AS total_marketing_expense,
			    ROUND(CASE WHEN p.price::money::numeric <= 2.5 THEN 25000
			   		  ELSE p.price::money::numeric * 10000 END, 2) AS rights_purchase_expense,
			    12 + 6 * ROUND(p.rating / 0.25,0)          AS lifespan_months,
				NULL       AS app_store_rating,
				p.rating   AS play_store_rating,
				p.rating   AS weighted_avg_rating,
				NULL       AS app_store_review_count,
				p.review_count AS play_store_review_count,
				NULL       AS app_store_price,
				p.price::money::numeric AS play_store_price,
				p.price::money::numeric AS weighted_avg_price,
				NULL       AS app_store_content_rating,
				p.content_rating AS play_store_content_rating,
				NULL       AS app_store_primary_genre,
				p.category AS play_store_category,
				p.genres   AS play_store_genres
FROM ps_apps_max_review_count p LEFT JOIN app_store_apps a USING(name)
WHERE a.name IS NULL
      AND p.rating IS NOT NULL
ORDER BY total_profit DESC;

----------------------------
--Selects records with the maximum review_count for each app.
SELECT play_store_apps_reduced.name, count(*)
FROM
	(SELECT DISTINCT *
	FROM play_store_apps AS p1
	WHERE p1.rating IS NOT NULL
		  AND p1.review_count = (SELECT MAX(review_count)
								 FROM play_store_apps AS p2
								 WHERE p2.name = p1.name)
	 ) as play_store_apps_reduced
GROUP BY play_store_apps_reduced.name
ORDER BY count(*) desc;

