require Rails.root.join('spec/support/fixtures')

FactoryBot.define do
  factory(:user_portfolio_rebalancing, class: User::Portfolio::Rebalancing) do
    association :portfolio, factory: :user_portfolio
    requested_at Fixtures::DEFAULT_TIMESTAMP + 1.hour
    scheduled_at Fixtures::DEFAULT_TIMESTAMP + 2.hours
  end
end
