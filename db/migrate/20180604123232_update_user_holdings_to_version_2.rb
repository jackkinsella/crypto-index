class UpdateUserHoldingsToVersion2 < ActiveRecord::Migration[5.2]
  def change
    add_timestamps :user_holdings, null: false, index: true
  end
end
