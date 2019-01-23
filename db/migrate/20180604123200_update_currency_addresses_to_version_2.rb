class UpdateCurrencyAddressesToVersion2 < ActiveRecord::Migration[5.2]
  def change
    add_column :currency_addresses, :disabled_at, :datetime, index: true

    change_column_null :currency_addresses, :key_path, true

    add_index :currency_addresses, :created_at
    add_index :currency_addresses, :updated_at
  end
end
