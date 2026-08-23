-- missing values

SELECT
    COUNT(*) AS total_rows,
    COUNT(order_id) AS order_id_filled,
    COUNT(customer_id) AS customer_id_filled,
    COUNT(order_status) AS status_filled,
    COUNT(order_purchase_timestamp) AS purchase_date_filled
FROM olist_orders_dataset;


SELECT
    COUNT(*) AS total_products,
    COUNT(*) FILTER (WHERE product_category_name IS NULL) AS missing_categories,
    ROUND(100.0 * COUNT(*) FILTER (WHERE product_category_name IS NULL) / COUNT(*), 2) AS missing_category_percentage
FROM olist_products_dataset; --1.85% is missing


SELECT
    COUNT(*) AS total_rows,
    COUNT(order_id) AS order_id_filled,
    COUNT(product_id) AS product_id_filled,
    COUNT(seller_id) AS seller_id_filled,
    COUNT(price) AS price_filled
FROM olist_order_items_dataset;

SELECT
    COUNT(*) AS total_rows,
    COUNT(order_id) AS order_id_filled,
    COUNT(payment_type) AS payment_type_filled,
    COUNT(payment_value) AS payment_value_filled
FROM olist_order_payments_dataset;


SELECT COUNT(*) FILTER (WHERE customer_zip_code_prefix IS NULL) AS missing_zip
FROM olist_customers_dataset;

SELECT COUNT(*) FILTER (WHERE seller_zip_code_prefix IS NULL) AS missing_zip
FROM olist_sellers_dataset;


-- invalid values

SELECT
    COUNT(*) FILTER (WHERE price < 0) AS negative_prices,
    COUNT(*) FILTER (WHERE freight_value < 0) AS negative_freight
FROM olist_order_items_dataset;


SELECT
    COUNT(*) FILTER (WHERE product_weight_g <= 0) AS invalid_weight,
    COUNT(*) FILTER (WHERE product_length_cm <= 0) AS invalid_length,
    COUNT(*) FILTER (WHERE product_height_cm <= 0) AS invalid_height,
    COUNT(*) FILTER (WHERE product_width_cm <= 0) AS invalid_width
FROM olist_products_dataset;


SELECT
    COUNT(*) FILTER (WHERE payment_value < 0) AS invalid_payment_value,
    COUNT(*) FILTER (WHERE payment_installments < 1) AS invalid_installments
FROM olist_order_payments_dataset;

 -- 2 credit_card payments with 0 installments:
SELECT * 
FROM olist_order_payments_dataset
WHERE payment_installments < 1;

SELECT
	COUNT(*) FILTER (
	WHERE review_score NOT BETWEEN 1 AND 5) AS invalid_review_score
FROM
	olist_order_reviews_dataset;


SELECT
    COUNT(*) FILTER (
        WHERE order_approved_at < order_purchase_timestamp
    ) AS approved_before_purchase,

    COUNT(*) FILTER (
        WHERE order_delivered_customer_date < order_purchase_timestamp
    ) AS delivered_before_purchase,

    COUNT(*) FILTER (
        WHERE order_estimated_delivery_date < order_purchase_timestamp
    ) AS estimated_before_purchase
FROM olist_orders_dataset;


