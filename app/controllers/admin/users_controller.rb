module Admin
  class UsersController < AdminController
    def index
      impersonate(params[:impersonate]) if params[:impersonate].present?

      @users = action_cache {
        User.order(:email).to_a
      }
    end

    private

    def impersonate(email)
      user = User.find_by(email: email)

      session[:token] = user.log_in!
      storage.local[:freshchat] = freshchat_properties_for(user)

      redirect_to account_path
    end

    def freshchat_properties_for(user)
      {
        externalId: user.pid,
        firstName: user.first_name,
        email: user.email
      }
    end
  end
end
