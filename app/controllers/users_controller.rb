class UsersController < ApplicationController
  def create
    # TODO: This will show the 'blacklistedCountries' message
    # even when it's an IP ban due to suspiciously high usage.
    if KYC::Checks::VerifyIP.execute!(ip_address: request.remote_ip)
      begin
        if current_user&.email == create_params[:email]
          redirect_to(account_path) and return
        end

        sign_up_user

        render json: {success: true}
      rescue ActiveRecord::RecordInvalid
        render_error_json(
          user: User.new(create_params).tap(&:valid?)
        )
      end
    else
      render_error_json(user: @user, extra_errors: blacklisted_country_error)
    end
  end

  def update
    @user = current_user || raise_404
    evaluate_update_params!
    if on_sanctions_list?
      user.update!(banned_at: Time.now)
      render_error_json(extra_errors: information_concealing_error)
    else
      render json: {success: true}
    end
  rescue User::PhoneConfirmation::ConfirmationCodeInvalidError
    render_error_json(extra_errors: 'Invalid confirmation code')
  rescue User::PhoneConfirmation::ConfirmationCodeExpiredError
    render_error_json(extra_errors: 'Expired confirmation code')
  rescue AML::Checks::VerifyName::SanctionsRequestError
    render_error_json(extra_errors: information_concealing_error)
  rescue KYC::Checks::VerifyPostalAddress::VerificationError
    render_error_json(
      extra_errors: 'We had problems connecting to our address verification ' \
      'tool. Please try again in 10 seconds.'
    )
  rescue ActiveRecord::RecordInvalid
    render_error_json(user: @user)
  end

  def unsubscribe
    raise NotImplementedError
  end

  private

  attr_reader :user

  def sign_up_user
    @user = User.sign_up!(create_params[:email], request.remote_ip)
    UserMailer.signed_up(@user).deliver_later
  end

  def blacklisted_country_error
    <<-TEXT
      We detected that your IP address is from a country we are not allowed to
      serve (#{KYC::CountryPolicy::BLACKLISTED_COUNTRIES.to_sentence}).
      If you are using a proxy or a VPN, please disable it and try again.
    TEXT
  end

  def information_concealing_error
    'Error: Server down'
  end

  def evaluate_update_params!
    update_password! if update_params[:password].present?
    update_phone! if update_params[:phone_number].present?
    confirm_phone! if update_params[:phone_confirmation_code].present?
    activate_account! if params[:postal_address].present?
  end

  def update_password!
    user.update_password!(new_password: update_params[:password])
  end

  def update_phone!
    return if user.phone_confirmed?

    user.update!(
      phone: update_params.slice(:phone_country_code, :phone_number).values.join
    )
  end

  def confirm_phone!
    user.confirm_phone!(code: update_params[:phone_confirmation_code])
  end

  def activate_account!
    update_name_and_postal_address!

    return if user.addresses.deposit.exists?

    UserMailer.account_set_up(user).deliver_later
    user.account.addresses.deposit.generate_for!(
      owner: user.account,
      currency: Currency.eth,
      category: :deposit
    )
  end

  def update_name_and_postal_address!
    user.update!(
      first_name: update_params[:first_name],
      last_name: update_params[:last_name]
    )

    user.create_postal_address!(
      postal_address_params
    )
  end

  def on_sanctions_list?
    user.first_name? && user.last_name? && !AML::Checks::VerifyName.execute!(
      first_name: user.first_name,
      last_name: user.last_name
    )
  end

  def create_params
    params.require(:user).permit(:email)
  end

  def update_params
    params.require(:user).permit(
      :password, :phone_number, :phone_country_code,
      :phone_confirmation_code, :first_name, :last_name,
      :terms_accepted
    )
  end

  def postal_address_params
    params.require(:postal_address).permit(
      :street_line_1, :street_line_2, :zip_code,
      :city, :region, :country_alpha2_code
    )
  end

  def render_error_json(user: nil, extra_errors: [])
    error_messages = [
      user&.errors&.full_messages,
      user&.postal_address&.errors&.full_messages,
      Array.wrap(extra_errors)
    ].flatten.compact

    render json: {success: false, errorMessages: error_messages},
           status: :unprocessable_entity
  end
end
