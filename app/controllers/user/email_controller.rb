class User::EmailController < ApplicationController
  before_action :require_authentication, :require_level_1, only: :show

  def confirm
    if (user = User.find_by(email: confirm_params[:email]))
      confirm_email_for(user) and return
    else
      User.simulate_email_confirmation
    end

    raise_404
  end

  def show
    @email = obfuscate(current_user.email, reveal: 3)
  end

  private

  def confirm_email_for(user)
    if current_user.present?
      current_user.log_out!(token: session[:token])
      storage.local[:freshchat] = {}
    end

    if user.password?
      flash[:info] = 'Please enter your password to continue.'
      redirect_to(login_path(email: confirm_params[:email]))
    elsif user.confirm_email!(token: confirm_params[:token])
      session[:token] = user.log_in!

      redirect_to(new_account_path)
    end
  end

  def confirm_params
    params.slice(:token, :email)
  end
end
