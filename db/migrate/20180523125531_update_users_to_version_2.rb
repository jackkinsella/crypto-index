class UpdateUsersToVersion2 < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :password_digest, :string
    add_column :users, :email_confirmed_at, :datetime
    add_column :users, :phone, :string
    add_column :users, :phone_confirmed_at, :datetime

    add_index :users, :email_confirmed_at
    add_index :users, :phone, unique: true
    add_index :users, :phone_confirmed_at
  end
end
