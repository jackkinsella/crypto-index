module RailsModuleExtension
  def server?
    caller.any? { |line| line.start_with?('config.ru') }
  end

  def console?
    defined?(::Rails::Console).present?
  end
end
safe_monkey_patch_module(Rails, RailsModuleExtension)
