module Alerts
  class Capture < ApplicationAction
    def initialize(message:, details: {}, critical: false, throttle_for: nil)
      @message = critical ? "[Critical] #{message}" : message
      @details = details
      @critical = critical
      @throttle_interval = throttle_for
    end

    def execute!
      dispatch_alerts and return if throttle_interval.nil?
      throttle { dispatch_alerts }
    end

    private

    SEND_CRITICAL_ALERTS_TO = [
      'youremail@example.com'
    ].freeze

    attr_reader :message, :details, :critical, :throttle_interval

    def dispatch_alerts
      return unless critical

      SEND_CRITICAL_ALERTS_TO.map do |email|
        Messaging::SMS::SendJob.set(wait: 1.second).perform_later(
          user: User.find_by(email: email),
          text: message
        )
      end
    end

    def throttle
      digest = Digest::MD5.hexdigest(details.to_json)
      cache_key = "alerts::capture#throttle/digest=#{digest}"
      Rails.cache.fetch(cache_key, expires_in: throttle_interval) {
        yield
      }
    end
  end
end
