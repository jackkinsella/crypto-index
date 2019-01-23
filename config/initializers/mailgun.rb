if Rails.env.production?
  ActionMailer::Base.smtp_settings = {
    address: ENV['MAILGUN_SMTP_SERVER'],
    port: ENV['MAILGUN_SMTP_PORT'],
    user_name: ENV['MAILGUN_SMTP_LOGIN'],
    password: ENV['MAILGUN_SMTP_PASSWORD'],
    domain: ENV['MAILGUN_DOMAIN'],
    authentication: :plain
  }
end
