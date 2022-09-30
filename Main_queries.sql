
--RIGHTS PURCHASE PRICE

SELECT name,
	   CASE WHEN a.price <= 2.5 THEN 25000
            ELSE a.price * 10000 END AS rights_purchase_price
FROM app_store_apps a INNER JOIN play_store_apps p USING (name);

--STAR RATING

SELECT name, 
       (((app_store_apps.rating*app_store_apps.review_count::numeric)
		 + (play_store_apps.rating*play_store_apps.review_count))
		/ (app_store_apps.review_count::numeric + play_store_apps.review_count)) 
	   AS weighted_review_avg, app_store_apps.price
FROM app_store_apps INNER JOIN play_store_apps USING(name)
ORDER BY weighted_review_avg DESC;

--LONGEVITY

--0 => 12 months
-- + 6 months per 0.25 of a star

SELECT name,
       a.rating,
	   12 + (6 * ROUND((a.rating / 0.25),0)) as lifespan_months
FROM app_store_apps a INNER JOIN play_store_apps p USING(name)
ORDER BY lifespan_months;

-----------------------
WITH app_weighted_reviews AS
	(SELECT name, 
		   (((app_store_apps.rating*app_store_apps.review_count::numeric)
			 + (play_store_apps.rating*play_store_apps.review_count))
			/ (app_store_apps.review_count::numeric + play_store_apps.review_count)) 
		   AS weighted_review_avg
	FROM app_store_apps INNER JOIN play_store_apps USING(name))

SELECT name,
	   a.price AS app_price,
	   CASE WHEN a.price <= 2.5 THEN 25000
            ELSE a.price * 10000 END AS rights_purchase_price,
       a.rating, 
	   p.rating,
	   wr.weighted_review_avg,
	   12 + (6 * ROUND((wr.weighted_review_avg / 0.25),0)) as lifespan_months
FROM app_store_apps a INNER JOIN play_store_apps p USING(name)
					  INNER JOIN app_weighted_reviews wr USING(name);
------------------					  
WITH app_weighted_reviews AS
	(SELECT name, 
		   (((app_store_apps.rating*app_store_apps.review_count::numeric)
			 + (play_store_apps.rating*play_store_apps.review_count))
			/ (app_store_apps.review_count::numeric + play_store_apps.review_count)) 
		   AS weighted_review_avg
	FROM app_store_apps INNER JOIN play_store_apps USING(name))
SELECT name,
	   (a.price * a.review_count::numeric) + (p.price::money::numeric * p.review_count) 
	     / (a.review_count::numeric + p.review_count) AS weighted_price,
	   CASE WHEN (a.price * a.review_count::numeric) + (p.price::money::numeric * p.review_count) 
	     / (a.review_count::numeric + p.review_count) <= 2.5 THEN 25000
            ELSE (a.price * a.review_count::numeric) + (p.price::money::numeric * p.review_count) 
	     / (a.review_count::numeric + p.review_count) * 10000 END AS rights_purchase_price,
       a.rating, 
	   p.rating,
	   wr.weighted_review_avg,
	   12 + (6 * ROUND((wr.weighted_review_avg / 0.25),0)) as lifespan_months,
	   2500 * (6 * ROUND((wr.weighted_review_avg / 0.25),0)) as monthly_revenue,
	   1000 * (6 * ROUND((wr.weighted_review_avg / 0.25),0)) as monthly_marketing_expense
FROM app_store_apps a INNER JOIN play_store_apps p USING(name)
					  INNER JOIN app_weighted_reviews wr USING(name);
					  
------------------					  
WITH app_weighted_avg AS
	(SELECT name, 
	       ((a.price * a.review_count::numeric) + (p.price::money::numeric * p.review_count)) 
	          / (a.review_count::numeric + p.review_count) AS weighted_avg_price,
		   (((a.rating*a.review_count::numeric) + (p.rating*p.review_count))
			 / (a.review_count::numeric + p.review_count)) AS weighted_avg_review
	FROM app_store_apps a INNER JOIN play_store_apps p USING(name))
SELECT name,
	   wa.weighted_avg_price,
	   CASE WHEN wa.weighted_avg_price <= 2.5 THEN 25000
            ELSE wa.weighted_avg_price * 10000 END AS rights_purchase_cost,
       a.rating, 
	   p.rating,
	   wa.weighted_avg_review,
	   12 + (6 * ROUND((wa.weighted_avg_review / 0.25),0)) as lifespan_months,
	   2500 * (6 * ROUND((wa.weighted_avg_review / 0.25),0)) as total_in_app_revenue,
	   1000 * (6 * ROUND((wa.weighted_avg_review / 0.25),0)) as total_marketing_expense,
	   ((2500 * (6 * ROUND((wa.weighted_avg_review / 0.25),0))) --monthly revenue
	   - (1000 * (6 * ROUND((wa.weighted_avg_review / 0.25),0))) --minus monthly marketing expense
	   - CASE WHEN wa.weighted_avg_price <= 2.5 THEN 25000    --minus rights purchase cost
              ELSE wa.weighted_avg_price * 10000 END)  
	   AS total_profit
FROM app_store_apps a INNER JOIN play_store_apps p USING(name)
					  INNER JOIN app_weighted_avg wa USING(name)
	   WHERE name like 'LEGO Batman: DC Super Heroes'
ORDER BY total_profit DESC;
					  
--"LEGO Batman: DC Super Heroes"	weighte avg price = 38509.07191454156122250341

-------------------------------
WITH app_weighted_avg AS
	(SELECT name, 
	       ((a.price * a.review_count::numeric) + (p.price::money::numeric * p.review_count)) 
	          / (a.review_count::numeric + p.review_count) AS weighted_avg_price,
		   (((a.rating*a.review_count::numeric) + (p.rating*p.review_count))
			 / (a.review_count::numeric + p.review_count)) AS weighted_avg_review
	FROM app_store_apps a INNER JOIN play_store_apps p USING(name))
SELECT name,
	   ROUND(wa.weighted_avg_price, 2) AS weighted_avg_price,
	   ROUND(CASE WHEN wa.weighted_avg_price <= 2.5 THEN 25000
            ELSE wa.weighted_avg_price * 10000 END, 2 )AS rights_purchase_cost,
       a.rating, 
	   p.rating,
	   ROUND(wa.weighted_avg_review,2), 
	   12 + (6 * ROUND((wa.weighted_avg_review / 0.25),0)) as lifespan_months,
	   2500 * (6 * ROUND((wa.weighted_avg_review / 0.25),0)) as total_in_app_revenue,
	   1000 * (6 * ROUND((wa.weighted_avg_review / 0.25),0)) as total_marketing_expense,
	   ROUND(((2500 * (6 * ROUND((wa.weighted_avg_review / 0.25),0))) --monthly revenue
	   - (1000 * (6 * ROUND((wa.weighted_avg_review / 0.25),0))) --minus monthly marketing expense
	   - CASE WHEN wa.weighted_avg_price <= 2.5 THEN 25000    --minus rights purchase cost
              ELSE wa.weighted_avg_price * 10000 END), 2)  
	   AS total_profit
FROM app_store_apps a INNER JOIN play_store_apps p USING(name)
					  INNER JOIN app_weighted_avg wa USING(name)
ORDER BY total_profit asc;

select * from app_store_apps where name like 'AnatomyMapp';
select * from play_store_apps where name like 'AnatomyMapp';

-------------------------------------------------------

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
	   12 + (6 * ROUND((wa.weighted_avg_review / 0.25),0)) as lifespan_months,
	   5000 * (12 + (6 * ROUND((wa.weighted_avg_review / 0.25),0))) as total_in_app_revenue,
	   1000 * (12 + (6 * ROUND((wa.weighted_avg_review / 0.25),0))) as total_marketing_expense,
	   ROUND(((5000 * (12 + (6 * ROUND((wa.weighted_avg_review / 0.25),0)))) --monthly revenue
	   - (1000 * (12 + (6 * ROUND((wa.weighted_avg_review / 0.25),0)))) --minus monthly marketing expense
	   - CASE WHEN wa.weighted_avg_price <= 2.5 THEN 25000    --minus rights purchase cost
              ELSE wa.weighted_avg_price * 10000 END), 2)  
	   AS total_profit
FROM app_store_apps a INNER JOIN play_store_apps p USING(name)
					  INNER JOIN app_weighted_avg wa USING(name)
ORDER BY total_profit DESC;
--coffee-cat
--heart-love-8-bit-zelda
--blob-bear-dance


SELECT DISTINCT a.name,
	   a.price,
	   ROUND(CASE WHEN a.price <= 2.5 THEN 25000
             ELSE a.price * 10000 END, 2 )AS rights_purchase_cost,
       a.rating, 
	   12 + (6 * ROUND((a.rating / 0.25),0)) as lifespan_months,
	   2500 * (12 + (6 * ROUND((a.rating / 0.25),0))) as total_in_app_revenue,
	   1000 * (12 + (6 * ROUND((a.rating / 0.25),0))) as total_marketing_expense,
	   ROUND(((5000 * (12 + (6 * ROUND((a.rating / 0.25),0)))) --monthly revenue
	   - (1000 * (12 + (6 * ROUND((a.rating / 0.25),0)))) --minus monthly marketing expense
	   - CASE WHEN a.price <= 2.5 THEN 25000    --minus rights purchase cost
              ELSE a.price * 10000 END), 2)  
	   AS total_profit
FROM app_store_apps a LEFT JOIN play_store_apps p USING(name)
WHERE p.name IS NULL
ORDER BY name DESC;










