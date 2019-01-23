FactoryBot.define do
  factory(:market_trade, class: Market::Trade) do
    category :user
    market
    association :initiator, factory: :user_account_deposit
    association :base_currency,
      factory: :currency, symbol: :LTC,
      name: 'litecoin', strategy: :find_or_create
    association :quote_currency,
      factory: :currency, symbol: :ETH, strategy: :find_or_create
    symbol :LTCETH
    order_side :BUY
    order_type :MARKET
    amount 1.to_d
  end
end
