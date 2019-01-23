module Valuations
  class Create < ApplicationAction
    def initialize(from_date: nil, to_date: nil, currencies: nil)
      @from_date = from_date || to_date || Date.today
      @to_date = to_date || @from_date
      @currencies = Array(currencies || Currency.order(:symbol))
    end

    def execute!
      (from_date..to_date).to_a.reverse_each do |date|
        currencies.each do |currency|
          create_valuations_for!(date, currency)
        end
      end
    end

    private

    attr_reader :from_date, :to_date, :currencies

    def create_valuations_for!(date, currency)
      return unless currency.available_at?(date)

      timestamped_readings = Time.partition(date, date.end_of_day).
        each_with_object({}) { |timestamp, readings| readings[timestamp] = [] }.
        merge(create_readings_for!(date, currency))

      timestamped_readings.each do |timestamp, readings|
        (readings += currency.valuation_readings.at(timestamp)).uniq!

        valuation = Valuation.find_or_initialize_by(
          currency: currency, timestamp: timestamp
        )

        begin
          valuation.update(readings: readings) if valuation.mutable?
        rescue ActiveRecord::RecordNotUnique
        end
      end
    end

    def create_readings_for!(date, currency)
      {}.tap do |readings|
        Valuation::Reading::SOURCE_NAMES.each do |source_name|
          source = "Sources::#{source_name.camelize}".constantize.new
          readings_from_source = currency.
            valuation_readings.from_source(source_name)

          if (source.expires? && date < Date.today) ||
              readings_present?(readings_from_source, date)
            readings_from_source.on(date).each do |reading|
              (readings[reading.timestamp] ||= []) << reading
            end
          else
            source_data = source.data_for(date: date, currency: currency)

            source_data[:valuations].each do |valuation_data|
              timestamp = valuation_data[:timestamp].round_down

              attributes = valuation_data.slice(
                :market_cap_usd, :price_usd, :circulating_supply
              ).merge(source_data: source_data)

              readings[timestamp] ||= []
              reading = create_reading!(
                currency, timestamp, source_name, attributes
              )
              readings[timestamp] << reading if reading.present?
            end
          end
        end
      end
    end

    def readings_present?(readings_from_source, date)
      number_of_readings = readings_from_source.on(date).count
      number_of_readings == Valuation.per_day ||
        (date.today? && number_of_readings >= Time.now.hour + 1)
    end

    def create_reading!(currency, timestamp, source_name, attributes)
      Valuation::Reading.create_with(attributes).find_or_create_by!(
        currency: currency, timestamp: timestamp, source_name: source_name
      )
    rescue ActiveRecord::RecordNotUnique
      currency.valuation_readings.at(timestamp).from_source(source_name).take
    rescue StandardError => error
      Alerts::Capture.execute!(
        message: 'A valuation reading could not be gathered',
        details: {
          exception: error.class.to_s,
          error_message: error.message,
          currency: currency.to_s,
          timestamp: timestamp,
          source_name: source_name
        },
        critical: true,
        throttle_for: 1.hour
      )
      nil
    end
  end
end
