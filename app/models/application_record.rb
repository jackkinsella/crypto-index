class ApplicationRecord < ActiveRecord::Base
  include ActionView::Helpers::DateHelper

  self.abstract_class = true

  WHITELISTED_ATTRIBUTES = [:email, :phone].freeze

  MAXIMUM_LENGTH = 100

  NAME_FORMAT = /\A[a-z0-9-]{1,100}\z/
  TOKEN_FORMAT = /\A[0-9A-Za-z]{24}\z/

  EMAIL_FORMAT = /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,16}\z/
  PHONE_FORMAT = /\A\+[0-9]{6,}\z/

  validates :created_at,
    presence: false

  validates :updated_at,
    presence: false

  scope :created_since, ->(time) { where('created_at > ?', time) }
  scope :updated_since, ->(time) { where('updated_at > ?', time) }

  def self.symbols_for(table_name)
    CSV.read_config_data(table_name).by_col[0]
  end
  singleton_class.send :alias_method, :names_for, :symbols_for

  def sanitized_attributes
    if Current.admin?
      attributes.except(*filtered_attributes.map(&:to_s))
    else
      {}
    end
  end

  protected

  def filtered_attributes
    Rails.application.config.filter_parameters - WHITELISTED_ATTRIBUTES
  end
end
