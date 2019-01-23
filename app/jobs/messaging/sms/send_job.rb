module Messaging
  module SMS
    class SendJob < ApplicationJob
      queue_as :mailers

      def perform(user:, text:)
        TwilioGateway::Message.to(user).send!(text: text)
      end
    end
  end
end
