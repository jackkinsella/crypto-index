class CreateUserSessions < ActiveRecord::Migration[5.2]
  def change
    create_table :user_sessions do |t|
      t.references :user, null: false, index: true, foreign_key: true
      t.string :token, null: false, index: {unique: true}
      t.timestamps null: false, index: true
    end
  end
end
