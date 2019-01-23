Rails.application.config.content_security_policy do |policy|
  policy.default_src :self, :https
  policy.font_src    :self, :https
  policy.form_action :self, :https
  policy.frame_src   :self, :https, 'wchat.freshchat.com'
  policy.img_src     :self, :https, :data
  policy.object_src  :none
  policy.script_src  :self, :https, 'wchat.freshchat.com'
  policy.style_src   :self, :https, :unsafe_inline

  if Rails.env.development?
    policy.report_uri '/security/violations'

    policy.connect_src :self, :https,
      'http://localhost:3035', 'ws://localhost:3035'
  end
end

Rails.application.config.content_security_policy_nonce_generator =
  ->(_request) { SecureRandom.base64(16) }
