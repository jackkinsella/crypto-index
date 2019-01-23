class UpdateValuationsToVersion2 < ActiveRecord::Migration[5.2]
  def change
    add_column :valuations, :stale, :boolean, null: false, default: false, index: true
  end
end
