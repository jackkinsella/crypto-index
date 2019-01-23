require File.expand_path('./shared/numerical_units', __dir__)

module FloatInstanceExtension
  include Shared::NumericalUnits

  def to_wei
    to_d.to_wei
  end
end
safe_monkey_patch_instance(Float, FloatInstanceExtension)
