class Market < ApplicationRecord
  include Nameable

  NAMES = names_for(:markets)

  has_many :trades, dependent: :restrict_with_exception

  validates :name,
    presence: true,
    uniqueness: true,
    inclusion: {in: NAMES}

  validates :title,
    presence: true,
    length: {maximum: MAXIMUM_LENGTH}

  def inbound_address
    @_inbound_address = Currency::Address.create_with(
      owner: self,
      currency: Currency.eth,
      category: :market_inbound
    ).find_or_create_by!(
      value: Rails.application.credentials.markets[name].addresses.inbound
    )
  end

  def trade_filters_for(symbol)
    raise NotImplementedError unless self == Market.binance

    config_file = "#{Rails.root}/config/data/markets/binance.json"
    @_config ||= JSON.parse(File.read(config_file)).with_indifferent_access

    entry = @_config[:symbols].find { |item| item[:symbol] == symbol }
    raise UnsupportedSymbolError if entry.nil?

    filter = entry[:filters].find { |item| item[:filterType] == 'LOT_SIZE' }

    {
      minimum_quantity: filter[:minQty].to_d,
      maximum_quantity: filter[:maxQty].to_d,
      step_size: filter[:stepSize].to_d
    }
  end

  class UnsupportedSymbolError < StandardError; end
end
