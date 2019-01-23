class CreateUserAccountWithdrawals < ActiveRecord::Migration[5.2]
  def change
    create_table :user_account_withdrawals do |t|
      t.references :account, null: false, index: true, foreign_key: {to_table: :user_accounts}
      t.references :currency, null: false, index: true, foreign_key: true
      t.decimal :fraction, precision: 32, scale: 12, null: false, index: true
      t.decimal :amount, precision: 32, scale: 12, index: true
      t.decimal :crypto_index_fee, precision: 32, scale: 12, index: true
      t.datetime :requested_at, null: false, index: true
      t.datetime :enabled_at, index: true
      t.datetime :released_at, index: true
      t.datetime :finalized_at, index: true
      t.timestamps null: false, index: true
    end
  end
end
