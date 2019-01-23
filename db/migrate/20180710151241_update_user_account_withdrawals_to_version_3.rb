class UpdateUserAccountWithdrawalsToVersion3 < ActiveRecord::Migration[5.2]
  def change
    add_column :user_account_withdrawals, :confirmed_by_email_at, :datetime
    add_column :user_account_withdrawals, :confirmed_by_phone_at, :datetime
  end
end
