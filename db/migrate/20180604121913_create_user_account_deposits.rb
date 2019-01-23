class CreateUserAccountDeposits < ActiveRecord::Migration[5.2]
  def change
    create_table :user_account_deposits do |t|
      t.references :account, null: false, index: true, foreign_key: {to_table: :user_accounts}
      t.references :currency, null: false, index: true, foreign_key: true
      t.decimal :amount, precision: 32, scale: 12, null: false, index: true
      t.decimal :crypto_index_fee, null: false, precision: 32, scale: 12, index: true
      t.datetime :received_at, null: false, index: true
      t.datetime :relayed_at, index: true
      t.datetime :finalized_at, index: true
      t.timestamps null: false, index: true
    end
  end
end
