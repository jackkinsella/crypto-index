class TimeValidator < ActiveModel::EachValidator
  attr_reader :resolution, :after, :before

  def initialize(options)
    super
    @resolution = options[:resolution]
    @after = options[:after]
    @before = options[:before]
  end

  def validate_each(*args)
    resolution_valid?(*args) || within_range?(*args)
  end

  private

  def resolution_valid?(record, attribute, value)
    return if resolution.nil? || value.nil? || (value.to_i % resolution).zero?
    record.errors[attribute] << "isn't divisible by #{resolution.inspect}"
  end

  def within_range?(*args)
    before_valid?(*args) || after_valid?(*args)
  end

  def before_valid?(record, attribute, value)
    return if before.nil? || value.nil? || value.to_i <= before.to_i
    record.errors[attribute] << "isn't before #{before.inspect}"
  end

  def after_valid?(record, attribute, value)
    return if after.nil? || value.nil? || value.to_i >= after.to_i
    record.errors[attribute] << "isn't after #{after.inspect}"
  end
end
