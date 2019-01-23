require Rails.root.join('spec/support/fixtures')

FactoryBot.define do
  factory(:index_allocation, class: Index::Allocation) do
    association :index, strategy: :find_or_create
    timestamp CryptoIndex::GENESIS_DATE.to_time

    transient do
      from_valuations []
    end

    before(:create) do |index_allocation, evaluator|
      if evaluator.from_valuations.present?
        total_market_cap = evaluator.from_valuations.sum(&:market_cap_usd)
        evaluator.from_valuations.each do |valuation|
          component_weight = valuation.market_cap_usd.to_d / total_market_cap
          index_allocation.components.push(
            build(
              :index_component,
              currency: valuation.currency,
              weight: component_weight
            )
          )
        end
      else
        currency_symbols = Fixtures::CURRENCY_SYMBOLS.first(10)

        currency_symbols.each do |currency_symbol|
          currency = find(:currency, symbol: currency_symbol) || create(
            :currency,
            symbol: currency_symbol,
            name: currency_symbol.downcase,
            title: currency_symbol
          )

          index_allocation.components.push(
            build(:index_component, currency: currency)
          )
        end
      end
    end
  end
end
