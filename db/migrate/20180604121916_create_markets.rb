class CreateMarkets < ActiveRecord::Migration[5.2]
  def change
    create_table :markets do |t|
      t.string :name, null: false, index: {unique: true}
      t.string :title, null: false, index: true
      t.timestamps null: false, index: true
    end
  end
end
