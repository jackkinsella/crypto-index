module Admin
  class ValuationsController < AdminController
    def index
      @date = Date.parse(params[:date]) rescue Date.today.beginning_of_month
      @dates = Date.partition(CryptoIndex::GENESIS_DATE, Date.today).reverse

      @valuations = action_cache(:date) {
        Currency.order(:symbol).map { |currency| valuations_for(currency) }
      }
    end

    private

    def valuations_for(currency)
      {
        'symbol' => currency.to_s + (currency.rejected? ? '*' : ''),
        days => compile_scores_for(currency)
      }
    end

    def days
      (1..end_time.day).map { |day| "#{day} ".ljust(119, '.') }.join('  ')
    end

    def start_time
      @date.beginning_of_month.to_time
    end

    def end_time
      (@date + 1.month).beginning_of_month - 1.second
    end

    def compile_scores_for(currency)
      Time.partition(start_time, end_time).map { |timestamp|
        none = currency.available_at?(timestamp) ? '-   ' : '*   '
        (scores[[currency.id, timestamp]] || none) + ' '
      }.join.scan(/.{120}/).join(' ')
    end

    def scores
      @_valuation_presences ||= count(Valuation.all)
      @_trusted_evaluated_counts ||= count(Valuation::Reading.trusted.evaluated)
      @_available_counts ||= count(Valuation::Reading.all)

      @_scores ||= @_valuation_presences.keys.each_with_object({}) { |key, memo|
        next if @_valuation_presences[key].nil?
        trusted_evaluated_count = @_trusted_evaluated_counts[key] || 0
        available_count = @_available_counts[key] || 0
        memo[key] = "#{trusted_evaluated_count}(#{available_count})"
      }
    end

    def count(readings)
      readings.between(start_time, end_time + 1.second).
        group(:currency_id, :timestamp).count
    end
  end
end
