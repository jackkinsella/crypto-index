FactoryBot.define do
  factory(:user_account, class: User::Account) do
    association :user, strategy: :find_or_create
  end
end
