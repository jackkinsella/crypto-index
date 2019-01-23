module SessionHelper
  def current_session
    @_current_session ||= User::Session.find_by(token: session[:token])
  end

  def current_user
    @_current_user ||= current_session&.user
  end
end
