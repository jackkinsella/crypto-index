class CreateCurrencyAddresses < ActiveRecord::Migration[5.2]
  def change
    create_table :currency_addresses do |t|
      t.references :owner, null: false, index: true, polymorphic: true
      t.references :currency, null: false, index: true, foreign_key: true
      t.string :category, null: false, index: true
      t.string :value, null: false, index: {unique: true}
      t.string :key_path, null: false, index: {unique: true}
      t.timestamps null: false, index: false
    end
  end
end
