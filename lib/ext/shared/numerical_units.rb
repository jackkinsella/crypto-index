module Shared
  module NumericalUnits
    def prettify
      to_i == self ? to_i : self
    end

    def percent
      to_d
    end

    def as_fraction
      to_d * 0.01
    end

    def as_percent
      (self * 100).prettify
    end

    [:usd, :btc, :eth].each do |symbol|
      define_method(symbol) { to_d }
    end
  end
end
