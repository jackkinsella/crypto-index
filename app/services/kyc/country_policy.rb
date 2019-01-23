module KYC
  module CountryPolicy
    extend ActiveSupport::Concern

    BLACKLISTED_COUNTRY_CODES = %w[US].freeze
    WHITELISTED_COUNTRY_CODES =
      ISO3166::Country.all.map(&:alpha2) - BLACKLISTED_COUNTRY_CODES

    BLACKLISTED_COUNTRIES = BLACKLISTED_COUNTRY_CODES.map { |country_code|
      Country[country_code]
    }
    WHITELISTED_COUNTRIES = WHITELISTED_COUNTRY_CODES.map { |country_code|
      Country[country_code]
    }

    COUNTRY_NAME_TO_ALPHA2_MAPPING =
      ISO3166::Country.all.map(&:name).zip(
        ISO3166::Country.all.map(&:alpha2)
      ).sort.to_h

    def in_supported_country?(code:)
      BLACKLISTED_COUNTRY_CODES.exclude?(code)
    end
  end
end
