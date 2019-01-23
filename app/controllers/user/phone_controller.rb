class User::PhoneController < ApplicationController
  before_action :require_authentication
  before_action :require_level_1, only: :show

  def resend_confirmation_code
    current_user.send_phone_confirmation_code

    render json: {
      success: true, flashMessages: ['Confirmation code sent again'], step: 3
    }
  end

  def show
    @phone = obfuscate(current_user.phone, reveal: 4)
  end
end
