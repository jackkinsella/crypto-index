Rails.application.config.session_store(
  :cookie_store,
  key: '_session',
  expire_after: Rails.env.test? ? 10.years : 24.hours
)

Rails.application.config.action_dispatch.cookies_serializer = :json
Rails.application.config.action_dispatch.signed_cookie_digest = 'SHA256'
