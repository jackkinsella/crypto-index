class CryptoIndex::Fee
  PERCENTAGES = {
    deposit: 1.percent,
    withdrawal: 1.percent,
    rebalancing: 0.1.percent
  }.to_open_struct

  class << self
    def for_deposit_of(amount)
      (amount * percentages.deposit).as_fraction
    end

    def for_withdrawal_of(amount)
      (amount * percentages.withdrawal).as_fraction
    end

    def for_rebalancing_of(amount)
      (amount * percentages.rebalancing).as_fraction
    end

    def percentages
      if Rails.env.test? || Date.today >= CryptoIndex::LAUNCH_DATE
        PERCENTAGES
      else
        {
          deposit: 0.percent,
          withdrawal: 0.percent,
          rebalancing: 0.percent
        }.to_open_struct
      end
    end
  end
end
