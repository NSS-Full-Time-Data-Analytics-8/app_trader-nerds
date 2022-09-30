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