module Charting
  class Data < ApplicationService
    def initialize(chartable)
      @strategy = strategy_for(chartable)
      @start_time = chartable.start_time
      @end_time = chartable.end_time
    end

    def self.for(chartable)
      new(chartable)
    end

    def from(start_time)
      tap do
        self.start_time = start_time.round_down
      end
    end

    def to(end_time)
      tap do
        self.end_time = end_time.round_down
      end
    end

    def compile
      strategy.compile(timestamps)
    end

    private

    attr_reader :strategy
    attr_accessor :start_time, :end_time

    def timestamps
      if start_time.nil? || end_time.nil?
        []
      elsif end_time - start_time < 6.months
        hourly_timestamps
      else
        daily_timestamps
      end
    end

    def daily_timestamps
      Time.partition(
        start_time.beginning_of_day, end_time, resolution: 1.day
      )
    end

    def hourly_timestamps
      Time.partition(
        start_time, end_time, resolution: 1.hour
      )
    end

    def strategy_for(chartable)
      strategy_name = chartable.class.to_s.demodulize
      "::Charting::Strategies::#{strategy_name}".constantize.new(chartable)
    end
  end
end
