--- Q1 ---
SELECT
user_pseudo_id
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_20210131`,
UNNEST(items) AS item
WHERE item.item_name IS NOT NULL
AND item.item_name != '(not set)'
LIMIT 1

SELECT
e.user_pseudo_id,
TIMESTAMP_MICROS(e.event_timestamp) AS event_datetime,
e.event_name,
e.event_params,
e.user_properties,
e.items
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_20210131` e
JOIN UNNEST(e.items) AS item
WHERE e.user_pseudo_id = '1540124.2144280285'
AND item.item_name IS NOT NULL
AND item.item_name != ''
AND item.item_name != '(not set)'
LIMIT 1

--- Q2 ---

SELECT
e.user_pseudo_id,
TIMESTAMP_MICROS(e.event_timestamp) AS event_datetime,
e.event_name,
e.event_params,
e.user_properties,
e.items
ARRAY_LENGTH(e.event_params) AS event_params_count,
ARRAY_LENGTH(e.user_properties) AS user_properties_count,
ARRAY_LENGTH(e.items) AS items_count
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_20210131` e
JOIN UNNEST(e.items) AS item
WHERE e.user_pseudo_id = '1540124.2144280285'
AND item.item_name IS NOT NULL
AND item.item_name != ''
AND item.item_name != '(not set)'
LIMIT 1

--- Q3 ---

SELECT
e.user_pseudo_id,
e.event_name,
ep.key,
ep.value.string_value,
ep.value.int_value,
ep.value.double_value
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_20210131` AS e
LEFT JOIN UNNEST(e.event_params) AS ep
WHERE e.user_pseudo_id IS NOT NULL
  AND ep.key IS NOT NULL
  AND ep.key != ""
  AND ep.key NOT IN ("(not set)", "(not_set)")
ORDER BY ep.key ASC
LIMIT 1;

--- Q4 ---

SELECT
ep.key,
COUNT(*) AS key_frequency
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` AS e
LEFT JOIN UNNEST(e.event_params) AS ep
WHERE _TABLE_SUFFIX BETWEEN '20210101' AND '20211231'
GROUP BY ep.key
ORDER BY key_frequency DESC;

--- Q5 ---

select
e.user_pseudo_id,
TIMESTAMP_MICROS(e.event_timestamp) AS event_datetime,
item.item_id,
item.item_name,
item.item_category,
item.price,
item.quantity
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_20210131` e
JOIN UNNEST(e.items) AS item

--- Q6 ---

SELECT
  item.item_id,
  item.item_name,
  COUNT(*) AS events_count,
  SUM(item.quantity) AS total_quantity,
  SUM(item.price * item.quantity) AS total_revenue
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_20210131`,
UNNEST(items) AS item
GROUP BY
  item.item_id,
  item.item_name
ORDER BY
  total_revenue DESC;

--- Q7 ---
SELECT *
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_20210131` e
WHERE EXISTS (
  SELECT 1
  FROM UNNEST(e.items) AS item
  WHERE item.item_category = 'Apparel'
);

--- Q8 ---

SELECT
  _TABLE_SUFFIX AS event_date,
  COUNT(DISTINCT user_pseudo_id) AS unique_users,
  COUNT(*) AS total_events,
  COUNTIF(event_name = 'purchase') AS purchase_events
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
GROUP BY
  event_date
ORDER BY
  event_date ASC;


--- Q9 ---

SELECT
  user_pseudo_id,
  total_spent,
  RANK() OVER (ORDER BY total_spent DESC) AS rank,
  DENSE_RANK() OVER (ORDER BY total_spent DESC) AS dense_rank,
  ROW_NUMBER() OVER (ORDER BY total_spent DESC) AS row_number
FROM (
  SELECT
    user_pseudo_id,
    SUM(item.price * item.quantity) AS total_spent
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`,
  UNNEST(items) AS item
  GROUP BY
    user_pseudo_id
)
ORDER BY
  total_spent DESC
LIMIT 20;

--- Q10 ---
SELECT
  event_name,
  COUNT(*) AS start_count
FROM (
  SELECT
    event_name,
    ROW_NUMBER() OVER (
      PARTITION BY user_pseudo_id, ga_session_id
      ORDER BY event_timestamp
    ) AS rn
  FROM (
    SELECT
      e.user_pseudo_id,
      e.event_name,
      e.event_timestamp,
      ep.value.int_value AS ga_session_id
    FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_20210131` e
    JOIN UNNEST(e.event_params) AS ep
    WHERE ep.key = 'ga_session_id'
  )
)
WHERE rn = 1
GROUP BY
  event_name
ORDER BY
  start_count DESC
LIMIT 1;





