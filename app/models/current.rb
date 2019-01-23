class Current < ActiveSupport::CurrentAttributes
  CONTEXTS = [:admin].freeze

  attribute :uuid, :request, :user, :title, :context

  def user_agent
    request&.user_agent
  end

  def user_ip
    request&.remote_ip
  end

  def locale
    request.env['HTTP_ACCEPT_LANGUAGE'].to_locale rescue nil
  end

  def browser
    @_browser = begin
      fingerprint_sources = (request&.env || {}).slice(
        'HTTP_ACCEPT_ENCODING',
        'HTTP_ACCEPT_LANGUAGE',
        'HTTP_DNT',
        'HTTP_USER_AGENT'
      )

      raise ArgumentError if fingerprint_sources.empty?

      OpenStruct.new(
        fingerprint: Digest::SHA256.new.hexdigest(fingerprint_sources.to_json)
      )
    rescue ArgumentError
      OpenStruct.new(fingerprint: nil)
    end
  end

  def context=(context)
    raise ArgumentError unless CONTEXTS.include?(context)
    super
  end

  def admin?
    context == :admin
  end
end
