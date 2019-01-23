FactoryBot.define do
  factory(:valuation_reading, class: Valuation::Reading) do
    association :currency, strategy: :find_or_create
    market_cap_usd 125_000_000_000.to_d
    price_usd 1_300.to_d
    circulating_supply { market_cap_usd / price_usd }
    source_name 'coin_market_cap'
    source_data '{}'
    timestamp { currency.trackable_at }
  end
end
