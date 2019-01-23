module Blockchains
  class AddressGenerator < ApplicationService
    def initialize(currency:, number:)
      @currency = currency
      @number = number

      raise ExceededMaximumNumberError if number > 2**31
    end

    def address
      case currency.symbol.to_sym
      when :BTC
        deterministic_wallet.bitcoin_address
      when :ETH
        deterministic_wallet.ethereum_address
      else
        raise UnsupportedCurrencyError
      end
    end

    def key_path
      "M/#{slip_044_coin_type}/#{number}"
    end

    class UnsupportedCurrencyError < StandardError; end
    class ExceededMaximumNumberError < StandardError; end

    private

    attr_reader :currency, :number

    def slip_044_coin_type
      case currency.symbol.to_sym
      when :BTC
        0
      when :ETH
        60
      end
    end

    def deterministic_wallet
      @_deterministic_wallet ||=
        DeterministicWallet::Derive.execute!(
          extended_key: Rails.application.credentials.
            blockchains.bip32.master_extended_public_key,
          key_path: key_path
        )
    end
  end
end
