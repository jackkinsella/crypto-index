module KYC
  module Checks
    class VerifyIP < ApplicationAction
      include CountryPolicy

      TIME_INTERVAL_FOR_SUSPICIOUS_IP_USAGE = 10.days
      THRESHOLD_FOR_SUSPICIOUS_IP_USAGE = Rails.env.development? ? 100 : 10

      def initialize(ip_address:)
        @ip_address = ip_address
      end

      def execute!
        verification_successful?.tap do |skip_alert|
          unless skip_alert
            Alerts::Capture.execute!(
              message: 'Suspicious usage of an IP address has been detected',
              details: {
                ip_address: ip_address,
                detected_country_code: detected_country_code
              }
            )
          end
        end
      end

      private

      attr_reader :ip_address, :phone_number

      def verification_successful?
        in_supported_country?(code: detected_country_code)
      end

      def normal_looking_usage_of_ip_address?
        User.created_since(TIME_INTERVAL_FOR_SUSPICIOUS_IP_USAGE.ago).
          where(ip_address: ip_address).count <
            THRESHOLD_FOR_SUSPICIOUS_IP_USAGE
      end

      def detected_country_code
        CountryDetection.country(ip_address).country_code2
      end
    end
  end
end
