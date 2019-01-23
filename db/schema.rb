# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_07_28_203151) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "currencies", force: :cascade do |t|
    t.string "symbol", null: false
    t.string "name", null: false
    t.string "title", null: false
    t.string "platform"
    t.decimal "maximum_supply", precision: 32, scale: 12
    t.datetime "trackable_at", null: false
    t.datetime "rejected_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_currencies_on_created_at"
    t.index ["name"], name: "index_currencies_on_name", unique: true
    t.index ["platform"], name: "index_currencies_on_platform"
    t.index ["rejected_at"], name: "index_currencies_on_rejected_at"
    t.index ["symbol"], name: "index_currencies_on_symbol", unique: true
    t.index ["title"], name: "index_currencies_on_title"
    t.index ["updated_at"], name: "index_currencies_on_updated_at"
  end

  create_table "currency/addresses", force: :cascade do |t|
    t.string "owner_type", null: false
    t.bigint "owner_id", null: false
    t.bigint "currency_id", null: false
    t.string "category", null: false
    t.string "value", null: false
    t.string "key_path"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "disabled_at"
    t.index ["category"], name: "index_currency/addresses_on_category"
    t.index ["created_at"], name: "index_currency/addresses_on_created_at"
    t.index ["currency_id"], name: "index_currency/addresses_on_currency_id"
    t.index ["key_path"], name: "index_currency/addresses_on_key_path", unique: true
    t.index ["owner_type", "owner_id"], name: "index_currency/addresses_on_owner_type_and_owner_id"
    t.index ["updated_at"], name: "index_currency/addresses_on_updated_at"
    t.index ["value"], name: "index_currency/addresses_on_value", unique: true
  end

  create_table "currency/transactions", force: :cascade do |t|
    t.bigint "currency_id", null: false
    t.string "sender_type", null: false
    t.bigint "sender_id", null: false
    t.string "receiver_type", null: false
    t.bigint "receiver_id", null: false
    t.bigint "from_address_id", null: false
    t.bigint "to_address_id", null: false
    t.decimal "value", precision: 32, scale: 12, null: false
    t.decimal "fee", precision: 32, scale: 12
    t.string "transaction_hash"
    t.jsonb "details", default: {}, null: false
    t.datetime "timestamp"
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "nonce", null: false
    t.index ["confirmed_at"], name: "index_currency/transactions_on_confirmed_at"
    t.index ["created_at"], name: "index_currency/transactions_on_created_at"
    t.index ["currency_id"], name: "index_currency/transactions_on_currency_id"
    t.index ["details"], name: "index_currency/transactions_on_details", using: :gin
    t.index ["fee"], name: "index_currency/transactions_on_fee"
    t.index ["from_address_id"], name: "index_currency/transactions_on_from_address_id"
    t.index ["nonce", "from_address_id"], name: "index_currency/transactions_on_nonce_and_from_address_id", unique: true
    t.index ["receiver_id"], name: "index_currency_transactions_on_received_deposit", unique: true, where: "((receiver_type)::text = 'User::Account::Deposit'::text)"
    t.index ["receiver_type", "receiver_id"], name: "index_currency/transactions_on_receiver_type_and_receiver_id"
    t.index ["sender_id"], name: "index_currency_transactions_on_relayed_deposit", unique: true, where: "((sender_type)::text = 'User::Account::Deposit'::text)"
    t.index ["sender_type", "sender_id"], name: "index_currency/transactions_on_sender_type_and_sender_id"
    t.index ["timestamp"], name: "index_currency/transactions_on_timestamp"
    t.index ["to_address_id"], name: "index_currency/transactions_on_to_address_id"
    t.index ["transaction_hash", "currency_id"], name: "index_currency_transactions_on_unique_columns", unique: true
    t.index ["transaction_hash"], name: "index_currency/transactions_on_transaction_hash"
    t.index ["updated_at"], name: "index_currency/transactions_on_updated_at"
    t.index ["value"], name: "index_currency/transactions_on_value"
  end

  create_table "index/allocations", force: :cascade do |t|
    t.bigint "index_id", null: false
    t.decimal "value", precision: 32, scale: 12, null: false
    t.datetime "timestamp", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_index/allocations_on_created_at"
    t.index ["index_id", "timestamp"], name: "index_index_allocations_on_unique_columns", unique: true
    t.index ["index_id"], name: "index_index/allocations_on_index_id"
    t.index ["timestamp"], name: "index_index/allocations_on_timestamp"
    t.index ["updated_at"], name: "index_index/allocations_on_updated_at"
    t.index ["value"], name: "index_index/allocations_on_value"
  end

  create_table "index/components", force: :cascade do |t|
    t.bigint "allocation_id", null: false
    t.bigint "currency_id", null: false
    t.decimal "weight", precision: 32, scale: 12, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["allocation_id", "currency_id"], name: "index_index_components_on_unique_columns", unique: true
    t.index ["allocation_id"], name: "index_index/components_on_allocation_id"
    t.index ["created_at"], name: "index_index/components_on_created_at"
    t.index ["currency_id"], name: "index_index/components_on_currency_id"
    t.index ["updated_at"], name: "index_index/components_on_updated_at"
    t.index ["weight"], name: "index_index/components_on_weight"
  end

  create_table "indexes", force: :cascade do |t|
    t.string "symbol", null: false
    t.string "name", null: false
    t.string "title", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_indexes_on_created_at"
    t.index ["name"], name: "index_indexes_on_name", unique: true
    t.index ["symbol"], name: "index_indexes_on_symbol", unique: true
    t.index ["title"], name: "index_indexes_on_title"
    t.index ["updated_at"], name: "index_indexes_on_updated_at"
  end

  create_table "market/trades", force: :cascade do |t|
    t.bigint "market_id", null: false
    t.string "initiator_type", null: false
    t.bigint "initiator_id", null: false
    t.bigint "base_currency_id", null: false
    t.bigint "quote_currency_id", null: false
    t.bigint "fee_currency_id"
    t.string "symbol", null: false
    t.string "category", null: false
    t.string "order_side", null: false
    t.string "order_type", null: false
    t.decimal "amount", precision: 32, scale: 12, null: false
    t.decimal "price", precision: 32, scale: 12
    t.decimal "fee", precision: 32, scale: 12
    t.jsonb "details", default: {}, null: false
    t.datetime "started_at"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["amount"], name: "index_market/trades_on_amount"
    t.index ["base_currency_id"], name: "index_market/trades_on_base_currency_id"
    t.index ["category"], name: "index_market/trades_on_category"
    t.index ["completed_at"], name: "index_market/trades_on_completed_at"
    t.index ["created_at"], name: "index_market/trades_on_created_at"
    t.index ["details"], name: "index_market/trades_on_details", using: :gin
    t.index ["fee"], name: "index_market/trades_on_fee"
    t.index ["fee_currency_id"], name: "index_market/trades_on_fee_currency_id"
    t.index ["initiator_type", "initiator_id", "base_currency_id", "quote_currency_id"], name: "index_market_trades_on_unique_columns", unique: true
    t.index ["initiator_type", "initiator_id"], name: "index_market/trades_on_initiator_type_and_initiator_id"
    t.index ["market_id"], name: "index_market/trades_on_market_id"
    t.index ["order_side"], name: "index_market/trades_on_order_side"
    t.index ["order_type"], name: "index_market/trades_on_order_type"
    t.index ["price"], name: "index_market/trades_on_price"
    t.index ["quote_currency_id"], name: "index_market/trades_on_quote_currency_id"
    t.index ["started_at"], name: "index_market/trades_on_started_at"
    t.index ["symbol"], name: "index_market/trades_on_symbol"
    t.index ["updated_at"], name: "index_market/trades_on_updated_at"
  end

  create_table "markets", force: :cascade do |t|
    t.string "name", null: false
    t.string "title", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_markets_on_created_at"
    t.index ["name"], name: "index_markets_on_name", unique: true
    t.index ["title"], name: "index_markets_on_title"
    t.index ["updated_at"], name: "index_markets_on_updated_at"
  end

  create_table "user/account/deposits", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "currency_id", null: false
    t.decimal "amount", precision: 32, scale: 12, null: false
    t.decimal "crypto_index_fee", precision: 32, scale: 12
    t.datetime "received_at", null: false
    t.datetime "relayed_at"
    t.datetime "finalized_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_user/account/deposits_on_account_id"
    t.index ["amount"], name: "index_user/account/deposits_on_amount"
    t.index ["created_at"], name: "index_user/account/deposits_on_created_at"
    t.index ["crypto_index_fee"], name: "index_user/account/deposits_on_crypto_index_fee"
    t.index ["currency_id"], name: "index_user/account/deposits_on_currency_id"
    t.index ["finalized_at"], name: "index_user/account/deposits_on_finalized_at"
    t.index ["received_at"], name: "index_user/account/deposits_on_received_at"
    t.index ["relayed_at"], name: "index_user/account/deposits_on_relayed_at"
    t.index ["updated_at"], name: "index_user/account/deposits_on_updated_at"
  end

  create_table "user/account/withdrawals", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "currency_id", null: false
    t.decimal "fraction", precision: 32, scale: 12, null: false
    t.decimal "amount", precision: 32, scale: 12
    t.decimal "crypto_index_fee", precision: 32, scale: 12
    t.datetime "requested_at", null: false
    t.datetime "arranged_at"
    t.datetime "collected_at"
    t.datetime "released_at"
    t.datetime "finalized_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "confirmed_by_email_at"
    t.datetime "confirmed_by_phone_at"
    t.index ["account_id"], name: "index_user/account/withdrawals_on_account_id"
    t.index ["amount"], name: "index_user/account/withdrawals_on_amount"
    t.index ["arranged_at"], name: "index_user/account/withdrawals_on_arranged_at"
    t.index ["collected_at"], name: "index_user/account/withdrawals_on_collected_at"
    t.index ["created_at"], name: "index_user/account/withdrawals_on_created_at"
    t.index ["crypto_index_fee"], name: "index_user/account/withdrawals_on_crypto_index_fee"
    t.index ["currency_id"], name: "index_user/account/withdrawals_on_currency_id"
    t.index ["finalized_at"], name: "index_user/account/withdrawals_on_finalized_at"
    t.index ["fraction"], name: "index_user/account/withdrawals_on_fraction"
    t.index ["released_at"], name: "index_user/account/withdrawals_on_released_at"
    t.index ["requested_at"], name: "index_user/account/withdrawals_on_requested_at"
    t.index ["updated_at"], name: "index_user/account/withdrawals_on_updated_at"
  end

  create_table "user/accounts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_user/accounts_on_created_at"
    t.index ["updated_at"], name: "index_user/accounts_on_updated_at"
    t.index ["user_id"], name: "index_user/accounts_on_user_id"
  end

  create_table "user/holdings", force: :cascade do |t|
    t.bigint "portfolio_id", null: false
    t.bigint "currency_id", null: false
    t.decimal "size", precision: 32, scale: 12, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["currency_id"], name: "index_user/holdings_on_currency_id"
    t.index ["portfolio_id", "currency_id"], name: "index_user_holdings_on_unique_columns", unique: true
    t.index ["portfolio_id"], name: "index_user/holdings_on_portfolio_id"
    t.index ["size"], name: "index_user/holdings_on_size"
  end

  create_table "user/passports", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "machine_readable_zone_enc", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_user/passports_on_created_at"
    t.index ["updated_at"], name: "index_user/passports_on_updated_at"
    t.index ["user_id"], name: "index_user/passports_on_user_id"
  end

  create_table "user/portfolio/compositions", force: :cascade do |t|
    t.bigint "portfolio_id", null: false
    t.decimal "value_usd", precision: 32, scale: 12, null: false
    t.decimal "value_btc", precision: 32, scale: 12, null: false
    t.decimal "value_eth", precision: 32, scale: 12, null: false
    t.decimal "return_on_investment", precision: 32, scale: 12, null: false
    t.decimal "tracking_error", precision: 32, scale: 12
    t.jsonb "constituents", default: [], null: false
    t.datetime "timestamp", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["constituents"], name: "index_user/portfolio/compositions_on_constituents", using: :gin
    t.index ["created_at"], name: "index_user/portfolio/compositions_on_created_at"
    t.index ["portfolio_id", "timestamp"], name: "index_user_portfolio_compositions_on_unique_columns", unique: true
    t.index ["portfolio_id"], name: "index_user/portfolio/compositions_on_portfolio_id"
    t.index ["return_on_investment"], name: "index_user/portfolio/compositions_on_return_on_investment"
    t.index ["timestamp"], name: "index_user/portfolio/compositions_on_timestamp"
    t.index ["tracking_error"], name: "index_user/portfolio/compositions_on_tracking_error"
    t.index ["updated_at"], name: "index_user/portfolio/compositions_on_updated_at"
    t.index ["value_btc"], name: "index_user/portfolio/compositions_on_value_btc"
    t.index ["value_eth"], name: "index_user/portfolio/compositions_on_value_eth"
    t.index ["value_usd"], name: "index_user/portfolio/compositions_on_value_usd"
  end

  create_table "user/portfolio/rebalancings", force: :cascade do |t|
    t.bigint "portfolio_id", null: false
    t.decimal "crypto_index_fee", precision: 32, scale: 12
    t.datetime "requested_at", null: false
    t.datetime "scheduled_at", null: false
    t.datetime "finalized_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_user/portfolio/rebalancings_on_created_at"
    t.index ["crypto_index_fee"], name: "index_user/portfolio/rebalancings_on_crypto_index_fee"
    t.index ["finalized_at"], name: "index_user/portfolio/rebalancings_on_finalized_at"
    t.index ["portfolio_id", "scheduled_at"], name: "index_user_portfolio_rebalancings_on_unique_columns", unique: true
    t.index ["portfolio_id"], name: "index_user/portfolio/rebalancings_on_portfolio_id"
    t.index ["requested_at"], name: "index_user/portfolio/rebalancings_on_requested_at"
    t.index ["scheduled_at"], name: "index_user/portfolio/rebalancings_on_scheduled_at"
    t.index ["updated_at"], name: "index_user/portfolio/rebalancings_on_updated_at"
  end

  create_table "user/portfolios", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user/portfolios_on_user_id", unique: true
  end

  create_table "user/postal_addresses", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "street_line_1_enc", null: false
    t.string "street_line_2_enc"
    t.string "zip_code_enc", null: false
    t.string "city_enc", null: false
    t.string "region_enc"
    t.string "country_alpha2_code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_alpha2_code"], name: "index_user/postal_addresses_on_country_alpha2_code"
    t.index ["created_at"], name: "index_user/postal_addresses_on_created_at"
    t.index ["updated_at"], name: "index_user/postal_addresses_on_updated_at"
    t.index ["user_id"], name: "index_user/postal_addresses_on_user_id"
  end

  create_table "user/sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "token", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_user/sessions_on_created_at"
    t.index ["token"], name: "index_user/sessions_on_token", unique: true
    t.index ["updated_at"], name: "index_user/sessions_on_updated_at"
    t.index ["user_id"], name: "index_user/sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.datetime "email_confirmed_at"
    t.string "phone"
    t.datetime "phone_confirmed_at"
    t.string "first_name_enc"
    t.string "last_name_enc"
    t.datetime "banned_at"
    t.string "ip_address"
    t.index ["created_at"], name: "index_users_on_created_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["email_confirmed_at"], name: "index_users_on_email_confirmed_at"
    t.index ["phone"], name: "index_users_on_phone", unique: true
    t.index ["phone_confirmed_at"], name: "index_users_on_phone_confirmed_at"
    t.index ["updated_at"], name: "index_users_on_updated_at"
  end

  create_table "valuation/readings", force: :cascade do |t|
    t.bigint "currency_id", null: false
    t.bigint "valuation_id"
    t.decimal "market_cap_usd", precision: 32, scale: 12
    t.decimal "price_usd", precision: 32, scale: 12
    t.decimal "circulating_supply", precision: 32, scale: 12
    t.string "source_name", null: false
    t.jsonb "source_data", default: {}, null: false
    t.datetime "timestamp", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_valuation/readings_on_created_at"
    t.index ["currency_id", "timestamp", "source_name"], name: "index_valuation_readings_on_unique_columns", unique: true
    t.index ["currency_id"], name: "index_valuation/readings_on_currency_id"
    t.index ["source_name"], name: "index_valuation/readings_on_source_name"
    t.index ["timestamp"], name: "index_valuation/readings_on_timestamp"
    t.index ["updated_at"], name: "index_valuation/readings_on_updated_at"
    t.index ["valuation_id"], name: "index_valuation/readings_on_valuation_id"
  end

  create_table "valuations", force: :cascade do |t|
    t.bigint "currency_id", null: false
    t.decimal "market_cap_usd", precision: 32, scale: 12, null: false
    t.decimal "price_usd", precision: 32, scale: 12, null: false
    t.decimal "circulating_supply", precision: 32, scale: 12, null: false
    t.datetime "timestamp", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "stale", default: false, null: false
    t.index ["circulating_supply"], name: "index_valuations_on_circulating_supply"
    t.index ["created_at"], name: "index_valuations_on_created_at"
    t.index ["currency_id", "timestamp"], name: "index_valuations_on_unique_columns", unique: true
    t.index ["currency_id"], name: "index_valuations_on_currency_id"
    t.index ["market_cap_usd"], name: "index_valuations_on_market_cap_usd"
    t.index ["price_usd"], name: "index_valuations_on_price_usd"
    t.index ["timestamp"], name: "index_valuations_on_timestamp"
    t.index ["updated_at"], name: "index_valuations_on_updated_at"
  end

  add_foreign_key "currency/addresses", "currencies"
  add_foreign_key "currency/transactions", "\"currency/addresses\"", column: "from_address_id"
  add_foreign_key "currency/transactions", "\"currency/addresses\"", column: "to_address_id"
  add_foreign_key "currency/transactions", "currencies"
  add_foreign_key "index/allocations", "indexes"
  add_foreign_key "index/components", "\"index/allocations\"", column: "allocation_id"
  add_foreign_key "index/components", "currencies"
  add_foreign_key "market/trades", "currencies", column: "base_currency_id"
  add_foreign_key "market/trades", "currencies", column: "fee_currency_id"
  add_foreign_key "market/trades", "currencies", column: "quote_currency_id"
  add_foreign_key "market/trades", "markets"
  add_foreign_key "user/account/deposits", "\"user/accounts\"", column: "account_id"
  add_foreign_key "user/account/deposits", "currencies"
  add_foreign_key "user/account/withdrawals", "\"user/accounts\"", column: "account_id"
  add_foreign_key "user/account/withdrawals", "currencies"
  add_foreign_key "user/accounts", "users"
  add_foreign_key "user/holdings", "\"user/portfolios\"", column: "portfolio_id"
  add_foreign_key "user/holdings", "currencies"
  add_foreign_key "user/passports", "users"
  add_foreign_key "user/portfolio/compositions", "\"user/portfolios\"", column: "portfolio_id"
  add_foreign_key "user/portfolio/rebalancings", "\"user/portfolios\"", column: "portfolio_id"
  add_foreign_key "user/portfolios", "users"
  add_foreign_key "user/postal_addresses", "users"
  add_foreign_key "user/sessions", "users"
  add_foreign_key "valuation/readings", "currencies"
  add_foreign_key "valuation/readings", "valuations"
  add_foreign_key "valuations", "currencies"

  create_view "valuation_indicators", materialized: true,  sql_definition: <<-SQL
      SELECT last_value(valuations.id) OVER twenty_four_hours AS valuation_id,
      valuations."timestamp",
          CASE
              WHEN ((last_value(valuations."timestamp") OVER twenty_four_hours - first_value(valuations."timestamp") OVER twenty_four_hours) = '23:00:00'::interval) THEN avg(valuations.market_cap_usd) OVER twenty_four_hours
              ELSE NULL::numeric
          END AS market_cap_usd_moving_average_24h,
          CASE
              WHEN ((last_value(valuations."timestamp") OVER twenty_four_hours - first_value(valuations."timestamp") OVER twenty_four_hours) = '23:00:00'::interval) THEN avg(valuations.price_usd) OVER twenty_four_hours
              ELSE NULL::numeric
          END AS price_usd_moving_average_24h,
          CASE
              WHEN ((last_value(valuations."timestamp") OVER twenty_four_hours - first_value(valuations."timestamp") OVER twenty_four_hours) = '23:00:00'::interval) THEN avg(valuations.circulating_supply) OVER twenty_four_hours
              ELSE NULL::numeric
          END AS circulating_supply_moving_average_24h,
          CASE
              WHEN ((last_value(valuations."timestamp") OVER twenty_four_hours - first_value(valuations."timestamp") OVER twenty_four_hours) = '23:00:00'::interval) THEN (last_value(valuations.price_usd) OVER twenty_four_hours - first_value(valuations.price_usd) OVER twenty_four_hours)
              ELSE NULL::numeric
          END AS price_change_24h,
          CASE
              WHEN ((last_value(valuations."timestamp") OVER twenty_four_hours - first_value(valuations."timestamp") OVER twenty_four_hours) = '23:00:00'::interval) THEN (((last_value(valuations.price_usd) OVER twenty_four_hours - first_value(valuations.price_usd) OVER twenty_four_hours) * (100)::numeric) / first_value(valuations.price_usd) OVER twenty_four_hours)
              ELSE NULL::numeric
          END AS price_change_24h_percent
     FROM valuations
    WINDOW twenty_four_hours AS (PARTITION BY valuations.currency_id ORDER BY valuations."timestamp" ROWS BETWEEN 23 PRECEDING AND CURRENT ROW);
  SQL

  add_index "valuation_indicators", ["valuation_id"], name: "index_valuation_indicators_on_valuation_id", unique: true

end
