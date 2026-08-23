-- PRIMARY KEYS

ALTER TABLE olist_orders_dataset 
ADD CONSTRAINT pk_orders PRIMARY KEY(order_id);

ALTER TABLE olist_customers_dataset
ADD CONSTRAINT pk_customers PRIMARY KEY (customer_id);

ALTER TABLE olist_products_dataset
ADD CONSTRAINT pk_products PRIMARY KEY (product_id);

ALTER TABLE olist_sellers_dataset
ADD CONSTRAINT pk_sellers PRIMARY KEY (seller_id);

ALTER TABLE product_category_name_translation
ADD CONSTRAINT pk_category_translation PRIMARY KEY (product_category_name);

ALTER TABLE olist_order_items_dataset
ADD CONSTRAINT pk_order_items PRIMARY KEY (order_id, order_item_id);

ALTER TABLE olist_order_payments_dataset
ADD CONSTRAINT pk_order_payments PRIMARY KEY (order_id, payment_sequential);

ALTER TABLE olist_order_reviews_dataset
ADD CONSTRAINT pk_order_reviews PRIMARY KEY (review_id, order_id);

-- FOREIGN KEYS

-- orders -> customers
ALTER TABLE olist_orders_dataset
ADD CONSTRAINT fk_orders_customers
FOREIGN KEY (customer_id) REFERENCES olist_customers_dataset (customer_id);

-- order_items -> orders
ALTER TABLE olist_order_items_dataset
ADD CONSTRAINT fk_order_items_orders
FOREIGN KEY (order_id) REFERENCES olist_orders_dataset (order_id);

-- order_items -> products
ALTER TABLE olist_order_items_dataset
ADD CONSTRAINT fk_order_items_products
FOREIGN KEY (product_id) REFERENCES olist_products_dataset (product_id);

-- order_items -> sellers
ALTER TABLE olist_order_items_dataset
ADD CONSTRAINT fk_order_items_sellers
FOREIGN KEY (seller_id) REFERENCES olist_sellers_dataset (seller_id);

-- order_payments -> orders
ALTER TABLE olist_order_payments_dataset
ADD CONSTRAINT fk_order_payments_orders
FOREIGN KEY (order_id) REFERENCES olist_orders_dataset (order_id);

-- order_reviews -> orders
ALTER TABLE olist_order_reviews_dataset 
ADD CONSTRAINT fk_order_reviews_orders
FOREIGN KEY(order_id) REFERENCES olist_orders_dataset (order_id);

-- category_name_translation -> products
ALTER TABLE olist_products_dataset
ADD CONSTRAINT fk_products_category_translation
FOREIGN KEY (product_category_name) REFERENCES product_category_name_translation (product_category_name);


-- indexes
CREATE INDEX idx_orders_customer_id ON olist_orders_dataset (customer_id);
CREATE INDEX idx_order_items_order_id ON olist_order_items_dataset (order_id);
CREATE INDEX idx_order_items_product_id ON olist_order_items_dataset (product_id);
CREATE INDEX idx_order_items_seller_id ON olist_order_items_dataset (seller_id);
CREATE INDEX idx_order_payments_order_id ON olist_order_payments_dataset (order_id);
CREATE INDEX idx_order_reviews_order_id ON olist_order_reviews_dataset (order_id);
CREATE INDEX idx_products_category ON olist_products_dataset (product_category_name);