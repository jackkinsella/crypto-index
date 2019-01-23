class CreateUserAccounts < ActiveRecord::Migration[5.2]
  def change
    create_table :user_accounts do |t|
      t.references :user, null: false, index: true, foreign_key: true
      t.timestamps null: false, index: true
    end

    reversible do |change|
      change.up do
        execute <<~SQL
          INSERT INTO user_accounts (user_id, created_at, updated_at)
          SELECT id, created_at, updated_at FROM users
        SQL
      end
    end
  end
end
