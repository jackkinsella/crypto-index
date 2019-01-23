SELECT
  last_value(valuations.id) OVER twenty_four_hours AS valuation_id,
  timestamp,
  CASE
    WHEN (
      (last_value(timestamp) OVER twenty_four_hours) -
      (first_value(timestamp) OVER twenty_four_hours)
    ) = '23:00:00' THEN AVG(market_cap_usd) OVER twenty_four_hours ELSE NULL
  END AS market_cap_usd_moving_average_24h,
  CASE
    WHEN (
      (last_value(timestamp) OVER twenty_four_hours) -
      (first_value(timestamp) OVER twenty_four_hours)
    ) = '23:00:00' THEN AVG(price_usd) OVER twenty_four_hours ELSE NULL
  END AS price_usd_moving_average_24h,
  CASE
    WHEN (
      (last_value(timestamp) OVER twenty_four_hours) -
      (first_value(timestamp) OVER twenty_four_hours)
    ) = '23:00:00' THEN AVG(circulating_supply) OVER twenty_four_hours ELSE NULL
  END AS circulating_supply_moving_average_24h,
  CASE
    WHEN (
      (last_value(timestamp) OVER twenty_four_hours) -
      (first_value(timestamp) OVER twenty_four_hours)
    ) = '23:00:00'
    THEN
      last_value(price_usd) OVER twenty_four_hours -
      first_value(price_usd) OVER twenty_four_hours
    ELSE NULL
  END AS price_change_24h,
  CASE
    WHEN (
      (last_value(timestamp) OVER twenty_four_hours) -
      (first_value(timestamp) OVER twenty_four_hours)
    ) = '23:00:00'
    THEN (
      last_value(price_usd) OVER twenty_four_hours -
      first_value(price_usd) OVER twenty_four_hours
    ) * 100 / first_value(price_usd) OVER twenty_four_hours
    ELSE NULL
  END AS price_change_24h_percent
FROM valuations
WINDOW twenty_four_hours AS (
  PARTITION BY valuations.currency_id
  ORDER BY valuations.timestamp ASC
  ROWS BETWEEN 23 PRECEDING AND CURRENT ROW
)
