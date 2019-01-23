class User::SecurityController < ApplicationController
  before_action :require_authentication, :require_level_1

  def show
    @deposit_address = current_user.account.addresses.
      deposit.order(:created_at).last.to_s
  end
end
