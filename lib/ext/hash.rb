module HashInstanceExtension
  def camelize_keys(first_letter = :lower)
    transform_keys { |key| key.to_s.camelize(first_letter).to_sym }
  end

  def camelize_keys!(first_letter = :lower)
    transform_keys! { |key| key.to_s.camelize(first_letter).to_sym }
  end

  def underscore_keys
    transform_keys { |key| key.to_s.underscore.to_sym }
  end

  def underscore_keys!
    transform_keys! { |key| key.to_s.underscore.to_sym }
  end

  def to_open_struct(hash = self)
    OpenStruct.new(hash.each_with_object({}) { |(key, value), memo|
      memo[key] = value.is_a?(Hash) ? to_open_struct(value) : value
    })
  end
end
safe_monkey_patch_instance(Hash, HashInstanceExtension)
