class CreateUserPassports < ActiveRecord::Migration[5.2]
  def change
    create_table :user_passports do |t|
      t.references :user, null: false, index: true, foreign_key: true
      t.string :machine_readable_zone_enc, null: false
      t.timestamps null: false, index: true
    end
  end
end
