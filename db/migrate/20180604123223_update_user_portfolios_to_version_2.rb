class UpdateUserPortfoliosToVersion2 < ActiveRecord::Migration[5.2]
  def change
    add_timestamps :user_portfolios, null: true, index: true

    reversible do |change|
      change.up do
        execute <<~SQL
          UPDATE user_portfolios
          SET (created_at, updated_at) = (
            SELECT created_at, updated_at
            FROM users
            WHERE users.id = user_portfolios.user_id
          )
        SQL
      end
    end

    change_column_null :user_portfolios, :created_at, false
    change_column_null :user_portfolios, :updated_at, false
  end
end
