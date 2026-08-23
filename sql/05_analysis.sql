-- SALES --

-- How has revenue changed over time?

SELECT 
    TO_CHAR(DATE_TRUNC('month', ood.order_purchase_timestamp), 'FMMonth YYYY') AS month_year,
    ROUND(SUM(ooid.price)::NUMERIC, 2) AS total_sales
FROM olist_orders_dataset ood 
JOIN olist_order_items_dataset ooid ON ooid.order_id = ood.order_id 
WHERE ood.order_status = 'delivered'
GROUP BY DATE_TRUNC('month', ood.order_purchase_timestamp)
ORDER BY DATE_TRUNC('month', ood.order_purchase_timestamp) ASC;


-- Which categories generate the most revenue?

SELECT
	pcnt.product_category_name_english,
	ROUND(SUM(ooid.price)::NUMERIC, 2) AS total_sales
FROM olist_order_items_dataset ooid
JOIN olist_products_dataset opd ON opd.product_id = ooid.product_id
JOIN product_category_name_translation pcnt ON pcnt.product_category_name = opd.product_category_name
JOIN olist_orders_dataset ood ON ood.order_id = ooid.order_id 
WHERE ood.order_status = 'delivered'
GROUP BY pcnt.product_category_name_english
ORDER BY total_sales DESC 

-- Which states generate the most revenue?

SELECT
	ds.state_name,
	ROUND(SUM(ooid.price)::NUMERIC, 2) AS total_sales
FROM olist_orders_dataset ood 
JOIN olist_order_items_dataset ooid ON ooid.order_id = ood.order_id 
JOIN olist_customers_dataset ocd ON ocd.customer_id = ood.customer_id 
JOIN dim_states ds ON ds.state_code = ocd.customer_state 
WHERE ood.order_status = 'delivered'
GROUP BY ds.state_name
ORDER BY total_sales DESC;

--What is the average order value?

WITH order_totals AS (
SELECT
	ooid.order_id,
	SUM(ooid.price) AS order_total
FROM olist_order_items_dataset ooid
JOIN olist_orders_dataset ood ON ooid.order_id = ood.order_id
WHERE ood.order_status = 'delivered'
GROUP BY ooid.order_id
 )
 
 SELECT ROUND(AVG(order_total)::NUMERIC, 2) AS avg_order_value
FROM order_totals;

--How many orders were placed per month (volume, not just revenue)?

SELECT
    TO_CHAR(DATE_TRUNC('month', ood.order_purchase_timestamp), 'FMMonth YYYY') AS month_year,
    COUNT(DISTINCT ood.order_id) AS total_orders
FROM olist_orders_dataset ood
JOIN olist_order_items_dataset ooid ON ooid.order_id = ood.order_id
WHERE ood.order_status = 'delivered'
GROUP BY DATE_TRUNC('month', ood.order_purchase_timestamp)
ORDER BY DATE_TRUNC('month', ood.order_purchase_timestamp) ASC;

-- What is the top-selling category within each state?

WITH top_categories AS (
    SELECT
	    ds.state_name,
	    pcnt.product_category_name_english ,
	    ROUND(SUM(ooid.price)::NUMERIC, 2) AS total_revenue,
	    RANK() OVER(PARTITION BY ds.state_name ORDER BY SUM(ooid.price) DESC) AS ranked_categories_by_state
    FROM olist_orders_dataset ood
    JOIN olist_customers_dataset ocd ON ocd.customer_id = ood.customer_id 
    JOIN dim_states ds ON ds.state_code = ocd.customer_state 
    JOIN olist_order_items_dataset ooid ON ooid.order_id = ood.order_id 
    JOIN olist_products_dataset opd ON opd.product_id = ooid.product_id 
    JOIN product_category_name_translation pcnt ON pcnt.product_category_name = opd.product_category_name
    WHERE ood.order_status = 'delivered'
    GROUP BY 1,2
    ORDER BY total_revenue DESC
)

SELECT *
FROM top_categories
WHERE ranked_categories_by_state = 1;


--  CUSTOMERS --

-- What percentage of customers are repeat buyers? 

SELECT
    ROUND(100.0 * COUNT(*) FILTER (WHERE order_count > 1) / COUNT(*), 2) AS pct_repeat_buyers
FROM (
    SELECT ocd.customer_unique_id, COUNT(DISTINCT ood.order_id) AS order_count
    FROM olist_customers_dataset ocd
    JOIN olist_orders_dataset ood ON ood.customer_id = ocd.customer_id
    GROUP BY ocd.customer_unique_id
) customer_orders;


-- Which states have the most customers?

SELECT
	ds.state_name,
	COUNT(DISTINCT ocd.customer_unique_id) AS total_customers
FROM olist_customers_dataset ocd 
JOIN dim_states ds ON ds.state_code = ocd.customer_state 
GROUP BY ds.state_name 
ORDER BY total_customers DESC; 


-- DELIVERY --

-- What is the average delivery time?

SELECT
    ROUND(
        AVG(
            EXTRACT(EPOCH FROM ood.order_delivered_customer_date - ood.order_purchase_timestamp) / 86400
        ), 2
     ) AS avg_delivery_time_days
FROM olist_orders_dataset ood
WHERE ood.order_status = 'delivered';

-- What percentage of orders are delivered late (actual date vs. estimated date)?

SELECT
	ROUND(
		100.0 * COUNT(*) FILTER (WHERE ood.order_delivered_customer_date > ood.order_estimated_delivery_date)
		/ COUNT (*)
	, 2
) AS pct_late_deliveries
FROM olist_orders_dataset ood
WHERE ood.order_status = 'delivered';

-- How does average delivery time vary by state?

SELECT
	ds.state_name,
	ROUND(
        AVG(
            EXTRACT(EPOCH FROM ood.order_delivered_customer_date - ood.order_purchase_timestamp) / 86400
        ), 2
     ) AS avg_delivery_time_days
FROM olist_orders_dataset ood
JOIN olist_customers_dataset ocd ON ocd.customer_id = ood.customer_id 
JOIN dim_states ds ON ds.state_code = ocd.customer_state 
WHERE ood.order_status = 'delivered'
GROUP BY ds.state_name
ORDER BY avg_delivery_time_days;

-- Estimated vs. actual delivery time

SELECT
    TO_CHAR(DATE_TRUNC('month', order_purchase_timestamp), 'FMMonth YYYY') AS month_year,
    ROUND(AVG(EXTRACT(EPOCH FROM order_estimated_delivery_date - order_purchase_timestamp)) / 86400, 2) AS avg_estimated_days,
    ROUND(AVG(EXTRACT(EPOCH FROM order_delivered_customer_date - order_purchase_timestamp)) / 86400, 2) AS avg_actual_days
FROM olist_orders_dataset
WHERE order_status = 'delivered'
GROUP BY DATE_TRUNC('month', order_purchase_timestamp)
ORDER BY DATE_TRUNC('month', order_purchase_timestamp);

-- What is the distribution of delivery times (bucketed)?

SELECT
    CASE
        WHEN EXTRACT(DAY FROM ood.order_delivered_customer_date - ood.order_purchase_timestamp) <= 3 THEN '0-3 days'
        WHEN EXTRACT(DAY FROM ood.order_delivered_customer_date - ood.order_purchase_timestamp) <= 7 THEN '4-7 days'
        WHEN EXTRACT(DAY FROM ood.order_delivered_customer_date - ood.order_purchase_timestamp) <= 14 THEN '8-14 days'
        WHEN EXTRACT(DAY FROM ood.order_delivered_customer_date - ood.order_purchase_timestamp) <= 30 THEN '15-30 days'
        ELSE '30+ days'
    END AS delivery_bucket,
    COUNT(*) AS total_orders
FROM olist_orders_dataset ood
WHERE ood.order_status = 'delivered'
GROUP BY delivery_bucket
ORDER BY MIN(EXTRACT(DAY FROM order_delivered_customer_date - order_purchase_timestamp));


--  REVIEWS / SATISFACTION 

-- What is the distribution of review scores (1–5)?

SELECT
	oord.review_score,
	COUNT(*) AS review_count
FROM olist_order_reviews_dataset oord 
GROUP BY oord.review_score;

-- What is the average review score by category (best/worst performers)?

SELECT
	pcnt.product_category_name_english,
	ROUND(AVG(oord.review_score), 2) AS avg_review_score
FROM olist_order_reviews_dataset oord 
JOIN olist_order_items_dataset ooid ON ooid.order_id = oord.order_id 
JOIN olist_products_dataset opd ON ooid.product_id = opd.product_id 
JOIN product_category_name_translation pcnt ON opd.product_category_name = pcnt.product_category_name 
GROUP BY pcnt.product_category_name_english
ORDER BY avg_review_score DESC;

-- Does review score correlate with delivery lateness (compare avg score for on-time vs. late orders)?

SELECT
	CASE
		WHEN ood.order_delivered_customer_date > ood.order_estimated_delivery_date THEN 'late'
		ELSE 'on time'
	END AS delivery_status,
	ROUND(AVG(oord.review_score), 2) AS avg_review_score,
	COUNT(*) AS order_count
FROM olist_orders_dataset ood 
JOIN olist_order_reviews_dataset oord ON oord.order_id = ood.order_id 
WHERE ood.order_delivered_customer_date IS NOT NULL
AND ood.order_estimated_delivery_date IS NOT NULL
GROUP BY delivery_status;

-- What percentage of delivered orders never received a review?

SELECT
	ROUND (
		100.0 * COUNT(*) FILTER (WHERE oord.review_id IS NULL) / COUNT(*)
	, 2) AS pct_no_reviews
FROM olist_orders_dataset ood 
LEFT JOIN olist_order_reviews_dataset oord ON oord.order_id = ood.order_id 
WHERE ood.order_status = 'delivered';

-- PAYMENTS --

-- What is the breakdown of orders by payment type?

SELECT
	oopd.payment_type,
	ROUND(
		COUNT(*) * 100.0 / (
			SELECT COUNT(*)
			FROM olist_order_payments_dataset
			)
	, 3) AS pct_payment_type
FROM olist_order_payments_dataset oopd
GROUP BY oopd.payment_type
ORDER BY pct_payment_type DESC;


