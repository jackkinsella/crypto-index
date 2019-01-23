FactoryBot.define do
  factory(:user_portfolio, class: User::Portfolio) do
    association :user, strategy: :build
  end
end
