class User::Portfolio < ApplicationRecord
  self.table_name = 'user/portfolios'

  belongs_to :user

  has_one :current_composition, -> { current_for(:portfolio) },
    class_name: 'User::Portfolio::Composition', inverse_of: :user_portfolio

  has_many :compositions, dependent: :restrict_with_exception

  has_many :holdings, dependent: :restrict_with_exception

  has_many :rebalancings, dependent: :restrict_with_exception

  has_many :deposits, through: :user

  delegate :end_time, to: :compositions

  delegate_missing_to :current_composition

  def start_time
    deposits.minimum(:received_at)&.round_up
  end

  def need_rebalancing?
    holdings.present? && rebalancings.not_finalized.empty?
  end
end
