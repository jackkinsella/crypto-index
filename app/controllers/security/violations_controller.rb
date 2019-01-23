module Security
  class ViolationsController < ApplicationController
    skip_before_action :verify_authenticity_token

    def create
      data = JSON.parse(request.body.read)

      if data['csp-report'].present?
        Rails.logger.info(
          Rainbow(
            JSON.pretty_generate(data['csp-report'].except('original-policy'))
          ).bold.red
        )
      end

      head :ok
    end
  end
end
