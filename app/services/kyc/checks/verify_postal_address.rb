module KYC
  module Checks
    class VerifyPostalAddress < ApplicationAction
      include Requests

      def initialize(postal_address:)
        @postal_address = postal_address
      end

      def execute!
        unless api_key
          Rails.logger.warn 'Google maps API key missing. '\
            'Skipping address validation'
          return true
        end
        @response = read_api(endpoint)

        check_for_api_problems!

        verification_successful?.tap do |skip_alert|
          unless skip_alert
            Alerts::Capture.execute!(
              message: 'A postal address could not be verified',
              details: {
                postal_address: postal_address.to_s
              }
            )
          end
        end
      rescue Requests::DownError => error
        raise VerificationError, error.message
      end

      class VerificationError < StandardError; end

      private

      attr_reader :postal_address, :response

      def verification_successful?
        results? && street_address?
      end

      def results?
        status != 'ZERO_RESULTS'
      end

      def street_address?
        response[:results].any? { |result|
          (result[:types] & accepted_address_types).present?
        }
      end

      def accepted_address_types
        %w[street_address premise subpremise route]
      end

      def check_for_api_problems!
        return if %w[OK ZERO_RESULTS].include?(status)
        raise VerificationError, "Received status code: #{status}"
      end

      def status
        response[:status]
      end

      def params
        {
          key: api_key,
          address: postal_address.to_s,
          components: [
            "admistrative_area:#{postal_address.city}",
            "route:#{postal_address.street_lines}"
          ].join('|')
        }
      end

      def endpoint
        "https://maps.googleapis.com/maps/api/geocode/json?#{params.to_query}"
      end

      def api_key
        Rails.application.credentials.services.google.maps_api_key
      end
    end
  end
end
