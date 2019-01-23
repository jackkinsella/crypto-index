FactoryBot.define do
  factory(:user_portfolio_composition, class: User::Portfolio::Composition) do
    user_portfolio
    timestamp CryptoIndex::GENESIS_DATE.to_time
    value_usd 1_000.to_d
    value_btc { value_usd / 5_000 }
    value_eth { value_usd / 1_000 }
    constituents {
      Fixtures::CURRENCY_SYMBOLS_IN_M10_AT[:genesis].
        each_with_object({}) { |symbol, res| res[symbol] = 1.to_d }
    }
    return_on_investment 1.to_d
  end
end
