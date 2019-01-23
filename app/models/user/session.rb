class User::Session < ApplicationRecord
  has_secure_token
  self.table_name = 'user/sessions'

  belongs_to :user

  validates :token,
    format: {with: TOKEN_FORMAT},
    allow_nil: true
end
