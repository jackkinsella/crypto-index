class CreateIndexComponents < ActiveRecord::Migration[5.2]
  def change
    create_table :index_components do |t|
      t.references :allocation, null: false, index: true, foreign_key: {to_table: :index_allocations}
      t.references :currency, null: false, index: true, foreign_key: true
      t.decimal :weight, precision: 32, scale: 12, null: false, index: true
      t.timestamps null: false, index: true
    end

    add_index :index_components, [:allocation_id, :currency_id], unique: true, name: 'index_index_components_on_unique_columns'
  end
end
