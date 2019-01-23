return if Rails.env.production?

module Twilio
  module REST
    class Client
      class << self
        def sent_messages
          @sent_messages ||= []
        end

        def clear_messages
          @sent_messages = nil
        end
      end

      def initialize(username = nil, password = nil)
      end

      attr_reader :sent_messages

      def messages
        Class.new {
          include Rails.application.routes.url_helpers

          class << self
            def default_url_options
              Rails.application.config.action_mailer.default_url_options
            end
          end

          def create(to:, from:, body:)
            Twilio::REST::Client.sent_messages.
              push(to: to, from: from, body: body)

            return unless Rails.env.development?

            Launchy.open(sms_opener_web_url(text: body))
          end
        }.new
      end
    end
  end
end
