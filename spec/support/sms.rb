module SMS
  extend ActiveSupport::Concern

  included do
    before { _sms_client.clear_messages }

    def last_sms
      _sms_client.sent_messages.last
    end

    def sms_messages_to(number)
      _sms_client.sent_messages.select { |message|
        message[:to] == number
      }
    end

    private

    def _sms_client
      Twilio::REST::Client
    end
  end
end
