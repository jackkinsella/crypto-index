module Immutable
  extend ActiveSupport::Concern

  included do
    class_attribute :_immutable, instance_writer: false
    self._immutable = {options: {if: proc { true }}}
  end

  class_methods do
    def immutable(options = {})
      _immutable[:options].merge!(options)
    end
  end

  def immutable?
    instance_exec &_immutable[:options][:if]
  end

  def mutable?
    !immutable?
  end

  def readonly?
    immutable? && !new_record? && !only_associations_updated?
  end

  private

  # Associations are not proper attributes and can be mutated.
  def only_associations_updated?
    changed_attributes.present? &&
    changed_attributes.keys.all? { |attribute| attribute.end_with?('_id') }
  end
end
