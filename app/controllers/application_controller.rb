class ApplicationController < ActionController::Base
  include ScreenTemplates
  include XHRRedirection
  include ApplicationHelper
  include ActionView::Helpers::DateHelper

  prepend_view_path 'app/views/templates'

  before_action do
    Current.request = request
    Current.user = current_user
    Current.title = CryptoIndex::TAGLINE
  end

  def require_authentication
    return if current_user.present?
    session[:redirect] = request.original_fullpath
    redirect_to login_path
  end

  def require_level_1
    return if current_user.level_1?
    redirect_to new_account_path
  end

  def raise_404
    raise ActionController::RoutingError,
      "No route matches [#{request.method}] #{request.path.inspect}"
  end
end
