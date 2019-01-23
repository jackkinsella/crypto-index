module KYC
  class CountryDetection
    class << self
      delegate_missing_to :geo_ip

      def geo_ip
        @geo_ip ||= GeoIP.new(geo_ip_database)
      end

      private

      def geo_ip_database
        "#{Rails.root}/vendor/geoip/GeoIP.dat"
      end
    end
  end
end
