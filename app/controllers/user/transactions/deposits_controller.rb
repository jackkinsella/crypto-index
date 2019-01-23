class User::Transactions::DepositsController < ApplicationController
  before_action :require_authentication, :require_level_1

  def index
    #
    # FIXME: Be very careful when adding Bitcoin deposits!
    #
    @deposit_address = current_user.account.addresses.
      deposit.order(:created_at).last.to_s
    @deposits = current_user.deposits. # TODO: currently unused
      includes(:received_transaction).order(received_at: :desc).to_a
    @transactions = @deposits.map(&:received_transaction)
  end
end
