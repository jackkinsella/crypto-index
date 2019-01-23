class User::AccountController < ApplicationController
  before_action :require_authentication
  before_action :require_level_1, only: :show

  def new
    @phone_country_codes = Phonelib.country_codes
  end

  def show
    @postal_address = obfuscate(current_user.postal_address.to_s)
  end
end
