class UpdateCurrenciesToVersion2 < ActiveRecord::Migration[5.2]
  def change
    rename_column :currencies, :released_at, :trackable_at
  end
end
