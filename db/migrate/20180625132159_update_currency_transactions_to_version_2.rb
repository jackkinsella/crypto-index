class UpdateCurrencyTransactionsToVersion2 < ActiveRecord::Migration[5.2]
  def change
    add_column :currency_transactions, :nonce, :integer
    add_index :currency_transactions, [:nonce, :from_address_id], unique: true

    reversible do |change|
      change.up do
        execute <<~SQL
          UPDATE currency_transactions
          SET nonce = (
            SELECT COUNT(*) AS nonce
            FROM currency_transactions previous_transactions
            WHERE
              previous_transactions.from_address_id =
              currency_transactions.from_address_id
            AND
              previous_transactions.created_at <
              currency_transactions.created_at
          )
        SQL
      end
    end

    change_column_null :currency_transactions, :nonce, false
  end
end
