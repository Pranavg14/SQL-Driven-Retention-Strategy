CREATE DATABASE customer_analysis;
USE customer_analysis;

SELECT value_tier,
       COUNT(*) AS customers,
       AVG(purchase_amount) AS avg_spend,
       AVG(loyalty_v1) AS avg_loyalty
FROM customers
GROUP BY value_tier;

SELECT promo_segment,
       AVG(frequency) AS avg_frequency,
       AVG(loyalty_v1) AS avg_loyalty,
       COUNT(*) AS customers
FROM customers
GROUP BY promo_segment;


SELECT category,
       AVG(loyalty_v1) AS avg_loyalty,
       AVG(purchase_amount) AS avg_spend,
       COUNT(*) AS customers
FROM customers
GROUP BY category
ORDER BY avg_loyalty DESC;


SELECT location,
       AVG(purchase_amount) AS avg_spend,
       AVG(promo_dependency) AS promo_usage,
       COUNT(*) AS customers
FROM customers
GROUP BY location
ORDER BY avg_spend DESC;

SELECT payment_method,
       AVG(loyalty_v1) AS avg_loyalty,
       AVG(purchase_amount) AS avg_spend,
       COUNT(*) AS customers
FROM customers
GROUP BY payment_method;


SELECT 
    value_tier,
    promo_segment,
    COUNT(*) AS customers,
    AVG(loyalty_v1) AS loyalty
FROM customers
GROUP BY value_tier, promo_segment;