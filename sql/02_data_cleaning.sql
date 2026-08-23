-- typecasting

ALTER TABLE olist_order_items_dataset 
ALTER COLUMN shipping_limit_date TYPE TIMESTAMP WITHOUT TIME ZONE 
USING shipping_limit_date::timestamp;

ALTER TABLE olist_orders_dataset 
ALTER COLUMN order_purchase_timestamp TYPE TIMESTAMP WITHOUT TIME ZONE USING NULLIF(order_purchase_timestamp, '')::timestamp,
ALTER COLUMN order_approved_at TYPE TIMESTAMP WITHOUT TIME ZONE,
ALTER COLUMN order_delivered_carrier_date TYPE TIMESTAMP WITHOUT TIME ZONE USING NULLIF(order_delivered_carrier_date, '')::timestamp,
ALTER COLUMN order_delivered_customer_date TYPE TIMESTAMP WITHOUT TIME ZONE USING NULLIF(order_delivered_customer_date, '')::timestamp,
ALTER COLUMN order_estimated_delivery_date TYPE TIMESTAMP WITHOUT TIME ZONE USING NULLIF(order_estimated_delivery_date, '')::timestamp;


-- cleanup

UPDATE olist_products_dataset
SET product_category_name = NULL
WHERE product_category_name = '';


SELECT DISTINCT p.product_category_name
FROM olist_products_dataset p
LEFT JOIN product_category_name_translation t
  ON p.product_category_name = t.product_category_name
WHERE p.product_category_name IS NOT NULL
  AND t.product_category_name IS NULL;


INSERT INTO product_category_name_translation (product_category_name, product_category_name_english)
VALUES
    ('pc_gamer', 'pc_gamer'),
    ('portateis_cozinha_e_preparadores_de_alimentos', 'kitchen_portable_and_food_preparers');


-- full names for states

CREATE TABLE dim_states (
    state_code VARCHAR(2) PRIMARY KEY,
    state_name VARCHAR(100)
);

SELECT DISTINCT(ocd.customer_state)
FROM olist_customers_dataset ocd; 

INSERT INTO dim_states (state_code, state_name)
VALUES
    ('AC', 'Acre'),
    ('AL', 'Alagoas'),
    ('AP', 'Amapá'),
    ('AM', 'Amazonas'),
    ('BA', 'Bahia'),
    ('CE', 'Ceará'),
    ('DF', 'Distrito Federal'),
    ('ES', 'Espírito Santo'),
    ('GO', 'Goiás'),
    ('MA', 'Maranhão'),
    ('MT', 'Mato Grosso'),
    ('MS', 'Mato Grosso do Sul'),
    ('MG', 'Minas Gerais'),
    ('PA', 'Pará'),
    ('PB', 'Paraíba'),
    ('PR', 'Paraná'),
    ('PE', 'Pernambuco'),
    ('PI', 'Piauí'),
    ('RJ', 'Rio de Janeiro'),
    ('RN', 'Rio Grande do Norte'),
    ('RS', 'Rio Grande do Sul'),
    ('RO', 'Rondônia'),
    ('RR', 'Roraima'),
    ('SC', 'Santa Catarina'),
    ('SP', 'São Paulo'),
    ('SE', 'Sergipe'),
    ('TO', 'Tocantins');

SELECT *
FROM dim_states;
