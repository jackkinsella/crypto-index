  class CreateCurrencyTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :currency_transactions do |t|
      t.references :currency, null: false, index: true, foreign_key: true
      t.references :sender, null: false, index: true, polymorphic: true
      t.references :receiver, null: false, index: true, polymorphic: true
      t.references :from_address, null: false, index: true, foreign_key: {to_table: :currency_addresses}
      t.references :to_address, null: false, index: true, foreign_key: {to_table: :currency_addresses}
      t.decimal :value, precision: 32, scale: 12, null: false, index: true
      t.decimal :fee, precision: 32, scale: 12, index: true
      t.string :transaction_hash, index: true
      t.jsonb :details, null: false, default: {}, index: {using: :gin}
      t.datetime :timestamp, index: true
      t.datetime :confirmed_at, index: true
      t.timestamps null: false, index: true
    end

    add_index :currency_transactions, [:transaction_hash, :currency_id], unique: true, name: 'index_currency_transactions_on_unique_columns'
    add_index :currency_transactions, :receiver_id, unique: true, where: 'receiver_type = \'User::Account::Deposit\'', name: 'index_currency_transactions_on_received_deposit'
    add_index :currency_transactions, :sender_id, unique: true, where: 'sender_type = \'User::Account::Deposit\'', name: 'index_currency_transactions_on_relayed_deposit'
  end
end
