FactoryBot.define do
  factory(:user_account_withdrawal, class: User::Account::Withdrawal) do
    currency
    user_account
    fraction 0.1
    requested_at Time.parse('1 Jan 2017 01:00')
  end
end
