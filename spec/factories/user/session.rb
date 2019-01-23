FactoryBot.define do
  factory(:user_session, class: User::Session) do
    user
  end
end
