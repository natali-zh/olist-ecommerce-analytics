SELECT * FROM OLIST_CUSTOMERS_DATASET OCD;
SELECT COUNT(*) FROM OLIST_CUSTOMERS_DATASET OCD;

SELECT * FROM olist_geolocation_dataset ogd;
SELECT COUNT(*) FROM olist_geolocation_dataset ogd;

SELECT * FROM olist_order_items_dataset ooid;
SELECT COUNT(*) FROM olist_order_items_dataset ooid;

SELECT * FROM olist_order_payments_dataset oopd;
SELECT COUNT(*) FROM olist_order_payments_dataset oopd;

SELECT * from olist_orders_dataset ood;
SELECT COUNT(*) FROM  olist_orders_dataset ood;

SELECT * FROM olist_products_dataset opd;
SELECT COUNT(*) FROM olist_products_dataset opd;

SELECT * FROM olist_sellers_dataset osd;
SELECT COUNT(*) FROM  olist_sellers_dataset osd;

SELECT * FROM olist_order_reviews_dataset oord;
SELECT COUNT(*) FROM olist_order_reviews_dataset oord;


SELECT DISTINCT order_status FROM olist_orders_dataset;
SELECT DISTINCT payment_type FROM olist_order_payments_dataset;

SELECT MIN(order_purchase_timestamp), MAX(order_purchase_timestamp) FROM olist_orders_dataset;