module NilClassExtension
  def to_d
    0.to_d
  end
end
safe_monkey_patch_instance(NilClass, NilClassExtension)
