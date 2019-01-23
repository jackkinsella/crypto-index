FactoryBot.define do
  factory(:valuation) do
    association :currency, strategy: :find_or_create
    timestamp CryptoIndex::GENESIS_DATE.to_time

    before(:create) do |valuation|
      if valuation.readings.empty?
        reading = find_or_create(
          :valuation_reading,
          currency: valuation.currency,
          timestamp: valuation.timestamp
        )
        valuation.readings.push(reading)
      end
    end
  end
end
