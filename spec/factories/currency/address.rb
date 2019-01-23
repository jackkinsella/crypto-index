require Rails.root.join('spec/support/blockchains/accounts')

FactoryBot.define do
  factory(:currency_address, class: Currency::Address) do
    Kernel.include(Blockchains::Accounts)

    association :currency, strategy: :find_or_create
    association :owner, factory: :user, strategy: :find_or_create
    category :user_inbound
    value ethereum_accounts.visitor.address
  end
end
