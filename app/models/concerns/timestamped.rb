module Timestamped
  extend ActiveSupport::Concern

  RESOLUTION = 1.hour

  included do
    validates :timestamp,
      presence: true,
      time: {resolution: RESOLUTION}

    scope :asc, -> { order(timestamp: :asc) }
    scope :desc, -> { order(timestamp: :desc) }

    scope :at, ->(timestamp) { where(timestamp: timestamp) }
    scope :on, ->(date) { between(date, date + 1.day) }

    scope :before, ->(time) { where('timestamp < ?', time) }
    scope :after, ->(time) { where('timestamp >= ?', time) }

    scope :between, ->(start_time, end_time) {
      where('timestamp >= ? AND timestamp < ?', start_time, end_time)
    }

    scope :current_for, ->(model) {
      where(<<~SQL)
        timestamp = (
          SELECT MAX(timestamp)
          FROM #{quoted_table_name} "#{table_name}_for_#{model}"
          WHERE #{quoted_table_name}.#{model}_id =
            "#{table_name}_for_#{model}".#{model}_id
          AND timestamp <= '#{Time.now.round_down.to_s(:db)}'
        )
      SQL
    }

    def self.resolution
      RESOLUTION
    end

    def self.per_day
      1.day / resolution
    end

    def self.start_time
      minimum(:timestamp)
    end

    def self.end_time
      maximum(:timestamp)
    end
  end
end
