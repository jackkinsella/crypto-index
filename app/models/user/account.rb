class User::Account < ApplicationRecord
  self.table_name = 'user/accounts'

  belongs_to :user
  has_one :portfolio, through: :user

  has_many :addresses,
    class_name: 'Currency::Address', as: :owner,
    inverse_of: :owner, dependent: :restrict_with_exception

  has_many :deposits, dependent: :restrict_with_exception

  has_many :rebalancings,
    through: :portfolio,
    class_name: 'User::Portfolio::Rebalancing'

  has_many :withdrawals, dependent: :restrict_with_exception

  def completed_trades
    Market::Trade.completed.where(initiator: deposits) +
    Market::Trade.completed.where(initiator: rebalancings) +
    Market::Trade.completed.where(initiator: withdrawals)
  end

  def allow_withdrawals_to!(address_value:)
    formatted_value = Eth::Utils.format_address(address_value)

    if Currency::Address.exists?(owner: user, category: :user_inbound)
      raise NotImplementedError, 'Can only use one address for withdrawals'
    end

    Currency::Address.create_with(
      owner: user,
      currency: Currency.eth, # TODO: Update for Bitcoin withdrawals
      category: :user_inbound
    ).find_or_create_by!(
      value: formatted_value
    )
  end
end
