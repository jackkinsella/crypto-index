class CreateUserPortfolios < ActiveRecord::Migration[5.2]
  def change
    create_table :user_portfolios do |t|
      t.references :user, null: false, index: {unique: true}, foreign_key: true
    end

    reversible do |change|
      change.up do
        execute <<~SQL
          INSERT INTO user_portfolios (user_id)
          SELECT id FROM users
        SQL
      end
    end
  end
end
