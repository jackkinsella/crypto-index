require File.expand_path('./shared/numerical_units', __dir__)

module IntegerInstanceExtension
  include Shared::NumericalUnits

  def to_eth
    to_d / 1_000_000_000_000_000_000
  end

  def to_wei
    to_d.to_wei
  end
end
safe_monkey_patch_instance(Integer, IntegerInstanceExtension)
