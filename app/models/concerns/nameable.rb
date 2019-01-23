module Nameable
  extend ActiveSupport::Concern

  class_methods do
    def method_missing(method, *arguments, &block)
      name = method.to_s.dasherize
      _nameable_by_symbol(name) || _nameable_by_name(name) || super
    end

    def respond_to_missing?(method, _include_private = false)
      super # No need for a database query
    end

    private_class_method
    def _nameable_by_symbol(name)
      has_attribute?(:symbol) &&
      _nameable_symbols.include?(name.upcase) &&
      find_by(symbol: name.upcase)
    end

    private_class_method
    def _nameable_by_name(name)
      _nameable_names.include?(name) &&
      find_by(name: name)
    end

    private_class_method
    def _nameable_symbols
      @_nameable_symbols ||= pluck(:symbol)
    end

    private_class_method
    def _nameable_names
      @_nameable_names ||= pluck(:name)
    end
  end

  delegate :to_sym, to: :name

  def to_param
    name
  end
end
