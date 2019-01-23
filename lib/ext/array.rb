module ArrayInstanceExtension
  def mean
    sum / size rescue nil
  end
end
safe_monkey_patch_instance(Array, ArrayInstanceExtension)
