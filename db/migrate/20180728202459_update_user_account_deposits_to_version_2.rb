class UpdateUserAccountDepositsToVersion2 < ActiveRecord::Migration[5.2]
  def change
    change_column_null :user_account_deposits, :crypto_index_fee, true
  end
end
