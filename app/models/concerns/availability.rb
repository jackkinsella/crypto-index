module Availability
  extend ActiveSupport::Concern

  included do
    validates :trackable_at,
      presence: true,
      time: {
        resolution: 1.day,
        after: Time.parse('3 Jan 2009'),
        before: Time.now + 1.month
      }

    validates :rejected_at,
      time: {
        resolution: 1.day,
        after: Time.parse('3 Jan 2009'),
        before: Time.now + 1.month
      }

    scope :trackable, -> { where.not(trackable_at: nil) }
    scope :not_trackable, -> { where(trackable_at: nil) }

    scope :trackable_before, ->(time) {
      where('trackable_at <= ?', time)
    }

    scope :not_trackable_until, ->(time) {
      where.not(id: trackable_before(time))
    }

    scope :rejected, -> { where.not(rejected_at: nil) }
    scope :not_rejected, -> { where(rejected_at: nil) }

    scope :rejected_before, ->(time) {
      rejected.where('rejected_at <= ?', time)
    }

    scope :not_rejected_until, ->(time) {
      where.not(id: rejected_before(time))
    }

    scope :available_at, ->(time) {
      trackable_before(time).not_rejected_until(time)
    }
  end

  def trackable?
    trackable_at?
  end

  def trackable_before?(time)
    trackable_at <= time
  end

  def not_trackable_until?(time)
    !trackable_before?(time)
  end

  def rejected?
    rejected_at?
  end

  def rejected_before?(time)
    rejected? && rejected_at <= time
  end

  def not_rejected_until?(time)
    !rejected_before?(time)
  end

  def available_at?(time)
    trackable_before?(time) &&
    not_rejected_until?(time)
  end
end
