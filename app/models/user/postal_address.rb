class User::PostalAddress < ApplicationRecord
  include Encryptable
  include KYC::CountryPolicy

  self.table_name = 'user/postal_addresses'

  belongs_to :user

  encrypted_attributes :street_line_1, :street_line_2,
    :zip_code, :city, :region

  validates :street_line_1,
    presence: true

  validates :street_line_2,
    presence: false

  validates :zip_code,
    presence: true

  validates :city,
    presence: true

  validates :region,
    presence: false

  validates :country_alpha2_code,
    exclusion: {
      in: BLACKLISTED_COUNTRY_CODES,
      message: 'cannot currently be served by us'
    }

  validate :address_is_real

  before_validation do
    [:street_line_1, :street_line_2, :zip_code, :city, :region].each do |field|
      self[field]&.strip!
      self[field] = nil if field.blank?
    end
  end

  def country
    Country[country_alpha2_code].name
  end

  def street_lines
    [street_line_1, street_line_2].compact.join(', ')
  end

  def to_s
    [street_lines, zip_code, city, region, country].compact.join(', ')
  end

  private

  def address_is_real
    return if KYC::Checks::VerifyPostalAddress.execute!(postal_address: self)
    errors[:base] << 'The address could not be verified'
  end
end
