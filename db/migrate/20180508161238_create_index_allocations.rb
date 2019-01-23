class CreateIndexAllocations < ActiveRecord::Migration[5.2]
  def change
    create_table :index_allocations do |t|
      t.references :index, null: false, index: true, foreign_key: true
      t.decimal :value, precision: 32, scale: 12, null: false, index: true
      t.datetime :timestamp, null: false, index: true
      t.timestamps null: false, index: true
    end

    add_index :index_allocations, [:index_id, :timestamp], unique: true, name: 'index_index_allocations_on_unique_columns'
  end
end
