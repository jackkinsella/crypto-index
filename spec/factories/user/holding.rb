FactoryBot.define do
  factory(:user_holding, class: User::Holding) do
    association :portfolio, factory: :user_portfolio
    currency
    size 100
  end
end
