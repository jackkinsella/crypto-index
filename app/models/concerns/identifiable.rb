module Identifiable
  extend ActiveSupport::Concern

  def uid
    return if id.nil?
    "trd_#{Digest::SHA256.new.hexdigest("#{self.class}##{id}")}"
  end
end
