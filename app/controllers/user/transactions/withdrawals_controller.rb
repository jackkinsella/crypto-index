class User::Transactions::WithdrawalsController < ApplicationController
  before_action :require_authentication, :require_level_1

  def index
    #
    # FIXME: Be very careful when adding Bitcoin withdrawals!
    #
    @withdrawal_address = current_user.addresses.
      withdrawal.order(:created_at).last.to_s
    @withdrawals = current_user.withdrawals. # TODO: currently unused
      includes(:released_transaction).order(released_at: :desc).to_a
    @transactions = @withdrawals.map(&:released_transaction).compact
  end

  def confirm_by_email
    @withdrawal = current_user.withdrawals.find(params[:id])
    @withdrawal.confirm_email!(token: params[:token])
    redirect_to transactions_withdrawals_path,
      flash: {success: 'Withdrawal request confirmed!'}
  end
end
