class User::Passport < ApplicationRecord
  self.table_name = 'user/passports'

  include Encryptable

  belongs_to :user

  encrypted_attributes :machine_readable_zone

  validates :machine_readable_zone,
    presence: true
end
