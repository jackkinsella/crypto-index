class CreateUserPostalAddresses < ActiveRecord::Migration[5.2]
  def change
    create_table :user_postal_addresses do |t|
      t.references :user, null: false, index: true, foreign_key: true
      t.string :street_line_1_enc, null: false
      t.string :street_line_2_enc
      t.string :zip_code_enc, null: false
      t.string :city_enc, null: false
      t.string :region_enc
      t.string :country_alpha2_code, null: false, index: true
      t.timestamps null: false, index: true
    end
  end
end
