module Messaging
  module SMS
    module TwilioGateway
      class Message < ApplicationService
        def initialize(user)
          @user = user
        end

        def self.to(user)
          new(user)
        end

        def send!(text:)
          twilio.messages.create(
            to: user.phone,
            from: sender_phone,
            body: text
          )
        end

        private

        attr_reader :user

        def sender_phone
          credentials[:sender_phone]
        end

        def twilio
          ::Twilio::REST::Client.new(
            credentials[:account_sid],
            credentials[:auth_token]
          )
        end

        def credentials
          Rails.application.credentials.services.twilio
        end
      end
    end
  end
end
