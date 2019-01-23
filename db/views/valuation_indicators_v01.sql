SELECT
  id,
  currency_id,
  timestamp,
  CASE
    WHEN (
      (first_value(timestamp) OVER twenty_four_hours) -
      (last_value(timestamp) OVER twenty_four_hours)
    ) = '23:00:00' THEN AVG(market_cap_usd) OVER twenty_four_hours ELSE NULL
  END AS market_cap_usd_moving_average_24h,
  CASE
    WHEN (
      (first_value(timestamp) OVER twenty_four_hours) -
      (last_value(timestamp) OVER twenty_four_hours)
    ) = '23:00:00' THEN AVG(price_usd) OVER twenty_four_hours ELSE NULL
  END AS price_usd_moving_average_24h,
  CASE
    WHEN (
      (first_value(timestamp) OVER twenty_four_hours) -
      (last_value(timestamp) OVER twenty_four_hours)
    ) = '23:00:00' THEN AVG(circulating_supply) OVER twenty_four_hours ELSE NULL
  END AS circulating_supply_moving_average_24h,
  CASE
    WHEN (
      (first_value(timestamp) OVER twenty_four_hours) -
      (last_value(timestamp) OVER twenty_four_hours)
    ) = '23:00:00'
    THEN
      first_value(price_usd) OVER twenty_four_hours -
      last_value(price_usd) OVER twenty_four_hours
    ELSE NULL
  END AS price_change_24h,
  CASE
    WHEN (
      (first_value(timestamp) OVER twenty_four_hours) -
      (last_value(timestamp) OVER twenty_four_hours)
    ) = '23:00:00'
    THEN (
      first_value(price_usd) OVER twenty_four_hours -
      last_value(price_usd) OVER twenty_four_hours
    ) * 100 / first_value(price_usd) OVER twenty_four_hours
    ELSE NULL
  END AS price_change_24h_percent
FROM valuations
WINDOW twenty_four_hours AS (
  PARTITION BY valuations.currency_id
  ORDER BY valuations.timestamp DESC
  ROWS BETWEEN CURRENT ROW AND 23 FOLLOWING
)
