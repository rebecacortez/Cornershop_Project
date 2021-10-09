# 1. Calculate the number of orders per day of the week, distinguishing if the orders are on_demand.
SELECT dow , on_demand, COUNT(*) as quant FROM orders
GROUP BY dow, on_demand ORDER BY quant DESC;

# 2. Calculate the average quantity of distinct products that each order has, grouped by store.
CREATE TEMPORARY TABLE  count_unit
SELECT count(distinct(product_id)) as count_unit, order_id from order_product
GROUP BY order_product.order_id;

SELECT storebranch.store, AVG(count_unit) as average FROM count_unit
INNER JOIN orders ON count_unit.order_id = orders.order_id
INNER JOIN storebranch ON orders.store_branch_id = storebranch.store_branch_id
GROUP BY storebranch.store;


# 3. Calculate the average found rate(*) of the orders grouped by the product format and day of the week.
SELECT AVG(quantity_found/quantity) as found_rate, order_product.buy_unit, orders.dow FROM order_product
INNER JOIN orders ON order_product.order_id = orders.order_id
GROUP BY orders.dow, order_product.buy_unit 
ORDER BY order_product.buy_unit, orders.dow;

# 4. Calculate the average error and mean squared error of our estimation model for each hour of the day.
DROP TEMPORARY TABLE IF EXISTS midnight;
CREATE TEMPORARY TABLE midnight
SELECT hour(promised_time) as hours, CASE WHEN promised_time = '00:00:00' THEN '23:59:59' ELSE promised_time END as promised_time, 
actual_time  from orders;
SELECT AVG(time_to_sec(timediff (promised_time, actual_time))/60) as MAE, hours, AVG(power(time_to_sec(timediff(promised_time, actual_time))/60,2)) as MSE FROM midnight
GROUP BY hours;

# 5. Calculate the number of orders in which the picker_id and driver_id are different.
SELECT COUNT(DISTINCT order_id) FROM orders
WHERE picker_id <> driver_id
