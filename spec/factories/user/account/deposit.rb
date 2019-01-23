require Rails.root.join('spec/support/fixtures')

FactoryBot.define do
  factory(:user_account_deposit, class: User::Account::Deposit) do
    association :user_account, strategy: :find_or_create
    association :currency, strategy: :find_or_create
    amount 1.0.to_d
    crypto_index_fee 0
    received_at Fixtures::DEFAULT_TIMESTAMP
  end
end
