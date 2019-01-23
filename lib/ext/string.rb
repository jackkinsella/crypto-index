module StringInstanceExtension
  def extract_d
    multiplier_key = match(/([MBT]|cents)$/)&.[](0)&.to_sym
    multiplier = {
      cents: 0.01,
      M: 1_000_000,
      B: 1_000_000_000,
      T: 1_000_000_000_000
    }[multiplier_key] || 1

    number_extractor = /((?:\d+,)*\d+(?:\.\d+)?)/
    base_number = match(number_extractor).to_s.tr(',', '').to_d

    base_number * multiplier
  end

  def to_locale
    scan(/^[a-z]{2}-[A-Z]{2}/)&.first || scan(/^[a-z]{2}/)&.first
  end
end
safe_monkey_patch_instance(String, StringInstanceExtension)
