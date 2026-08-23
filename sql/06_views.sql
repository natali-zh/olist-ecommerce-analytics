-- order_facts
-- one row per order item
-- includes customer, product, review, and delivery data

DROP VIEW IF EXISTS order_facts;

CREATE VIEW order_facts AS
SELECT
    ood.order_id,
    ood.order_purchase_timestamp,
    ood.order_delivered_customer_date,
    ood.order_estimated_delivery_date,
    EXTRACT(EPOCH FROM ood.order_delivered_customer_date - ood.order_purchase_timestamp) / 86400 AS delivery_time_days,
    EXTRACT(EPOCH FROM ood.order_estimated_delivery_date - ood.order_purchase_timestamp) / 86400 AS estimated_delivery_days,
    CASE
        WHEN ood.order_delivered_customer_date > ood.order_estimated_delivery_date THEN TRUE
        ELSE FALSE
    END AS is_late,
    ocd.customer_unique_id,
    ds.state_name,
    ooid.product_id,
    pcnt.product_category_name_english,
    ooid.price,
    oord.review_score,
    CASE WHEN oord.review_id IS NULL THEN TRUE ELSE FALSE END AS has_no_review
FROM olist_orders_dataset ood
JOIN olist_order_items_dataset ooid ON ooid.order_id = ood.order_id
JOIN olist_customers_dataset ocd ON ocd.customer_id = ood.customer_id
JOIN dim_states ds ON ds.state_code = ocd.customer_state
JOIN olist_products_dataset opd ON opd.product_id = ooid.product_id
JOIN product_category_name_translation pcnt ON pcnt.product_category_name = opd.product_category_name
LEFT JOIN olist_order_reviews_dataset oord ON oord.order_id = ood.order_id
WHERE ood.order_status = 'delivered';


-- delivery_time_buckets
-- groups orders by delivery time

DROP VIEW IF EXISTS delivery_time_buckets;

CREATE VIEW delivery_time_buckets AS
SELECT
    order_id,
    CASE
        WHEN EXTRACT(DAY FROM order_delivered_customer_date - order_purchase_timestamp) <= 3 THEN '0-3 days'
        WHEN EXTRACT(DAY FROM order_delivered_customer_date - order_purchase_timestamp) <= 7 THEN '4-7 days'
        WHEN EXTRACT(DAY FROM order_delivered_customer_date - order_purchase_timestamp) <= 14 THEN '8-14 days'
        WHEN EXTRACT(DAY FROM order_delivered_customer_date - order_purchase_timestamp) <= 30 THEN '15-30 days'
        ELSE '30+ days'
    END AS delivery_bucket
FROM olist_orders_dataset
WHERE order_status = 'delivered';


-- state_geo
-- state coordinates for the map

DROP VIEW IF EXISTS state_geo;

CREATE VIEW state_geo AS 
SELECT
	ds.state_code,
	ds.state_name,
	AVG(ogd.geolocation_lat) AS avg_lat,
	AVG(ogd.geolocation_lng) AS avg_lng
FROM olist_geolocation_dataset ogd
JOIN dim_states ds ON ds.state_code = ogd.geolocation_state
GROUP BY ds.state_code, ds.state_name;


-- top_category_by_state

DROP VIEW IF EXISTS top_category_by_state;

CREATE VIEW top_category_by_state AS
WITH ranked AS (
    SELECT
        ds.state_name,
        pcnt.product_category_name_english,
        ROUND(SUM(ooid.price)::NUMERIC, 2) AS total_revenue,
        RANK() OVER (PARTITION BY ds.state_name ORDER BY SUM(ooid.price) DESC) AS rnk
    FROM olist_orders_dataset ood
    JOIN olist_customers_dataset ocd ON ocd.customer_id = ood.customer_id
    JOIN dim_states ds ON ds.state_code = ocd.customer_state
    JOIN olist_order_items_dataset ooid ON ooid.order_id = ood.order_id
    JOIN olist_products_dataset opd ON opd.product_id = ooid.product_id
    JOIN product_category_name_translation pcnt ON pcnt.product_category_name = opd.product_category_name
    WHERE ood.order_status = 'delivered'
    GROUP BY 1, 2
)
SELECT
    state_name,
    product_category_name_english AS top_category,
    total_revenue
FROM ranked
WHERE rnk = 1
ORDER BY state_name;