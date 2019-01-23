class UpdateUsersToVersion3 < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :first_name_enc, :string
    add_column :users, :last_name_enc, :string
    add_column :users, :banned_at, :datetime, index: true
    add_column :users, :ip_address, :string, index: true
  end
end
