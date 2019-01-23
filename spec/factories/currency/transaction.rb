require Rails.root.join('spec/support/blockchains/accounts')

FactoryBot.define do
  factory(:currency_transaction, class: Currency::Transaction) do
    Kernel.include(Blockchains::Accounts)

    association :currency
    association :sender, factory: :user
    association :receiver, factory: :market
    association :from_address,
      factory: :currency_address
    association :to_address,
      factory: :currency_address,
      value: ethereum_accounts.binance_inbound.address
    nonce 0
    value 0.1.to_d
    details '{}'
  end
end
