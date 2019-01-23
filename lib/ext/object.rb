module SafeMonkeyPatchExtension
  def safe_monkey_patch_instance(target, extension)
    extension.instance_methods.each do |m|
      if target.method_defined?(m)
        raise NameError,
          "#{target}##{m.to_s.tr(':', '')} already defined"
      end
    end
    target.include(extension)
  end

  def safe_monkey_patch_class(target, extension)
    extension.instance_methods.each do |m|
      if target.respond_to?(m)
        raise NameError,
          "#{target}.#{m.to_s.tr(':', '')} already defined"
      end
    end
    target.extend(extension)
  end

  alias safe_monkey_patch_module safe_monkey_patch_class
end
Object.include(SafeMonkeyPatchExtension)
