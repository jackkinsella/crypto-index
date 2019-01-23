class ApplicationService
  class << self
    def method_missing(method, *arguments, &block)
      instance = new rescue nil

      if instance.respond_to?(method)
        instance.send(method, *arguments, &block)
      else
        super
      end
    end

    def respond_to_missing?(method, _include_private = false)
      (new rescue nil).respond_to?(method)
    end
  end
end
