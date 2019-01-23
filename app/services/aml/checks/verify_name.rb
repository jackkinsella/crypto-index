module AML
  module Checks
    class VerifyName < ApplicationAction
      include Requests

      def initialize(first_name:, last_name:)
        @first_name = first_name
        @last_name = last_name
      end

      def execute!
        verification_successful?.tap do |skip_alert|
          unless skip_alert
            Alerts::Capture.execute!(
              message: 'A possibly sanctioned person has been detected',
              details: {
                full_name: full_name,
                url: endpoint(full_name)
              }
            )
          end
        end
      end

      class SanctionsRequestError < StandardError; end

      private

      attr_reader :first_name, :last_name

      def verification_successful?
        !on_sanctions_list?(full_name)
      end

      def on_sanctions_list?(full_name)
        html = read_page(endpoint(full_name))
        if html.match? 'No Results found'
          false
        elsif html.match?(/\d+ Entries found/)
          true
        else
          raise SanctionsRequestError
        end
      rescue Requests::DownError, Requests::NotFoundError
        raise SanctionsRequestError
      end

      def full_name
        "#{first_name} #{last_name}"
      end

      def endpoint(full_name)
        "https://www.sanctions.io/search/?sname=#{CGI.escape(full_name)}"
      end
    end
  end
end
