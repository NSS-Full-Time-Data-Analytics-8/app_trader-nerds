-------------------------------------------------------
-----APPS IN BOTH STORES-------------------------------

--This query returns every column from both tables that we may want for analysis in Excel.

--Two columns are commented out: 
--     play_store_apps.review_count
--     play_store_apps.category
--Including them causes extra records to appear in our results due to apps having multiple 
--records in play_store_apps with different values in those two columns.

--With those two columns commented out, we still have a small number of apps with extra records, 
--such as 'Solitaire' and 'Toca Life: City'; these are caused by differences in the review_count
--column large enough to affect the weighted average price (before rounding) which then affects rights_purchase_expense.

WITH app_weighted_avg AS
	(SELECT name, 
	       (a.price*a.review_count::numeric + p.price::money::numeric*p.review_count) 
	          / (a.review_count::numeric + p.review_count) AS weighted_avg_price,
		   (a.rating*a.review_count::numeric + p.rating*p.review_count)
			 / (a.review_count::numeric + p.review_count) AS weighted_avg_rating
	FROM app_store_apps a INNER JOIN play_store_apps p USING(name))
SELECT DISTINCT p.name,
	            'both' AS stores,
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
				--p.review_count AS play_store_review_count,
			    a.price AS app_store_price,
				p.price::money::numeric AS play_store_price,
			    ROUND(wa.weighted_avg_price, 2) AS weighted_avg_price,
				a.content_rating AS app_store_content_rating,
				p.content_rating AS play_store_content_rating,
				a.primary_genre AS app_store_primary_genre,
				--p.category AS play_store_category,
				p.genres AS play_store_genres
FROM app_store_apps a INNER JOIN play_store_apps p USING(name)
					  INNER JOIN app_weighted_avg wa USING(name)
--WHERE p.category NOT LIKE 'FAMILY'
ORDER BY total_profit DESC;
--ORDER BY p.name;

--------TEMP: Analysis of category = FAMILY
SELECT name, category, count(*)
FROM play_store_apps
WHERE name IN (SELECT DISTINCT name
				FROM play_store_apps
				WHERE category LIKE 'FAMILY')
	  AND category NOT LIKE 'FAMILY'
GROUP BY name, category
ORDER BY count(*);

SELECT distinct name
FROM play_store_apps
WHERE category LIKE 'FAMILY';

--------------------------------
----APPS IN APP STORE ONLY------

--I plan to update this query so that the result set will have the same fields as the above query for both stores.
--This way, we can combine the results in Excel with a consistent set of columns.

SELECT DISTINCT a.name,
	   a.price,
	   ROUND(CASE WHEN a.price <= 2.5 THEN 25000
             ELSE a.price * 10000 END, 2) AS rights_purchase_cost,
       a.rating, 
	   12 + 6 * ROUND(a.rating / 0.25,0)          as lifespan_months,
	   2500 * (12 + 6 * ROUND(a.rating / 0.25,0)) as total_revenue,
	   1000 * (12 + 6 * ROUND(a.rating / 0.25,0)) as total_marketing_expense,
	   ROUND(2500 * (12 + 6 * ROUND(a.rating / 0.25,0))   --total revenue
		     - 1000 * (12 + 6 * ROUND(a.rating / 0.25,0)) --minus total marketing expense
		     - CASE WHEN a.price <= 2.5 THEN 25000        --minus rights purchase cost
			    	ELSE a.price * 10000 END
	    	 , 2) AS total_profit						  --equals total profit
FROM app_store_apps a LEFT JOIN play_store_apps p USING(name)
WHERE p.name IS NULL
ORDER BY total_profit DESC;

---------------------------------
----APPS IN PLAY STORE ONLY------

--not yet written
