class User::SessionsController < ApplicationController
  def new
    redirect_to(account_path) if current_user.present?
  end

  def create
    if (user = User.find_by(email: create_params[:email]))
      if (user.authenticate(create_params[:password]) rescue false)
        session[:token] = user.log_in!
        storage.local[:freshchat] = freshchat_properties_for(user)

        redirect_to(redirect_path) and return
      end
    else
      User.simulate_authentication
    end

    render json: {success: false}, status: :unauthorized
  end

  def destroy
    if current_user.present?
      current_user.log_out!(token: session[:token])
      storage.local[:freshchat] = {}
    end

    redirect_to login_path, flash: {success: 'Logged out!'}
  end

  private

  def freshchat_properties_for(user)
    {
      externalId: user.pid,
      firstName: user.first_name,
      email: user.email
    }
  end

  def redirect_path
    relative_path = /\A(\/[a-z]+)+/
    return session[:redirect] if session[:redirect]&.match?(relative_path)
    account_path
  end

  def create_params
    params.require(:user).permit(:email, :password)
  end
end
