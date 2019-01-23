class CreateIndexes < ActiveRecord::Migration[5.2]
  def change
    create_table :indexes do |t|
      t.string :symbol, null: false, index: {unique: true}
      t.string :name, null: false, index: {unique: true}
      t.string :title, null: false, index: true
      t.timestamps null: false, index: true
    end
  end
end
