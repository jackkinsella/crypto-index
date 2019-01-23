class CreateCurrencies < ActiveRecord::Migration[5.2]
  def change
    create_table :currencies do |t|
      t.string :symbol, null: false, index: {unique: true}
      t.string :name, null: false, index: {unique: true}
      t.string :title, null: false, index: true
      t.string :platform, index: true
      t.decimal :maximum_supply, precision: 32, scale: 12
      t.datetime :released_at, null: false
      t.datetime :rejected_at, index: true
      t.timestamps null: false, index: true
    end
  end
end
