module XHRRedirection
  extend ActiveSupport::Concern

  included do
    alias_method :original_redirect_to, :redirect_to

    def redirect_to(options = {}, response_status = {})
      if request.xhr? && options.is_a?(String)
        response.set_header('X-Redirect-To', options)
      else
        original_redirect_to(options, response_status)
      end
    end
  end
end
