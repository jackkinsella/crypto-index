require File.expand_path('./shared/numerical_units', __dir__)

module BigDecimalInstanceExtension
  include Shared::NumericalUnits
end
safe_monkey_patch_instance(BigDecimal, BigDecimalInstanceExtension)

class BigDecimal
  def inspect
    "#{self}d"
  end

  def to_wei
    (self * 1_000_000_000_000_000_000).to_i
  end
end
