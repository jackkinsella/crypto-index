module Timing
  extend ActiveSupport::Concern

  def wait(duration = 1)
    sleep(duration)
  end
end
