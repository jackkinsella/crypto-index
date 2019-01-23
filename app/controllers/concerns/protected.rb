module Protected
  extend ActiveSupport::Concern

  included do
    before_action :authenticate, unless: -> { Rails.env.development? }
  end

  private

  def authenticate
    authenticate_or_request_with_http_basic do |name, password|
      name == credentials[:name] && password == credentials[:password]
    end
  end

  def credentials
    {
      name: Rails.application.credentials.admin.name,
      password: Rails.application.credentials.admin.password
    }
  end
end
