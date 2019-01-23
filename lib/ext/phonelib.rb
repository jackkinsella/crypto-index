module Phonelib
  def self.country_codes
    phone_data.keys.map { |country_code|
      phone_data[country_code][:country_code]
    }.sort.uniq
  end
end
