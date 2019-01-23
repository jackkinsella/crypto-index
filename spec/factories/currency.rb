FactoryBot.define do
  factory(:currency) do
    name 'ethereum'
    symbol 'ETH'
    title 'Ethereum'
    maximum_supply 146_975_853.to_d
    trackable_at Time.parse('28 Apr 2013')
  end
end
