module Blockchains
  module Ethereum
    class Network < ApplicationService
      NUMBER_OF_BLOCKS_BACK = 125

      def get_balances(addresses:)
        addresses = Array.wrap(addresses).map(&:to_s).map(&:downcase)

        addresses.each_with_object({}) do |address, memo|
          memo[address] = client.get_balance(address).to_eth
        end
      end

      def send_transaction(
        private_key:, from_address:, to_address:, value:, nonce:
      )
        raise ArgumentError, 'A nonce is required' if nonce.nil?

        if [to_address, from_address].any?(&:nil?)
          raise ArgumentError, 'Addresses cannot be nil'
        end

        from_address = from_address.to_s.downcase
        to_address = to_address.to_s.downcase

        raise ArgumentError, 'A nonce is required' if nonce.nil?
        raise ArgumentError, 'From address does not match private key' if
          from_address_inconsistent_with_private_key?(from_address, private_key)

        transaction = Eth::Tx.new(
          from: from_address,
          to: to_address,
          value: value.to_wei,
          data: '',
          nonce: nonce,
          gas_limit: 150_000,
          gas_price: 10_000_000_000
        )

        transaction.sign(Eth::Key.new(priv: private_key))

        client.eth_send_raw_transaction(transaction.hex)['result']
      end

      def list_transactions(addresses:, start_block: nil, direction: :IN)
        addresses = Array.wrap(addresses).map(&:to_s).map(&:downcase)

        start_block ||= [current_block_number - NUMBER_OF_BLOCKS_BACK, 0].max
        block_numbers = (start_block..current_block_number).to_a.reverse

        block_numbers.each_with_object([]) { |block_number, transactions|
          block = block_details(block_number)

          next unless block

          entries = block[:transactions].map(&:underscore_keys)

          transactions << entries.select { |transaction|
            if direction == :IN
              addresses.include?(transaction[:to])
            elsif direction == :OUT
              addresses.include?(transaction[:from])
            end
          }.map { |transaction|
            transaction.tap {
              transform_transaction_details(transaction, block)
            }
          }
        }.flatten
      end

      def transaction_details(transaction_hash:)
        request(:eth_getTransactionByHash, transaction_hash).tap do |data|
          transform_transaction_details(data) if data.present?
        end
      end

      def number_of_confirmations(transaction_hash:)
        details = transaction_details(transaction_hash: transaction_hash)
        current_block_number - details[:block_number] rescue 0
      end

      def current_block_number
        request(:eth_blockNumber).to_i(16)
      end

      def get_nonce(from_address)
        request(:eth_getTransactionCount, from_address.to_s, 'pending').to_i(16)
      end

      private

      def from_address_inconsistent_with_private_key?(from_address, private_key)
        Eth::Key.new(priv: private_key).to_address.downcase != from_address
      end

      def transform_transaction_details(data, block = nil)
        data[:transaction_hash] = data.delete(:hash)
        data[:nonce] = data[:nonce].to_i(16)
        data[:gas] = data[:gas].to_i(16)
        data[:gas_price] = data[:gas_price].to_i(16)
        data[:from_address] = format_address(data.delete(:from))
        data[:to_address] = format_address(data.delete(:to))
        data[:value] = data[:value].to_i(16).to_eth
        data[:fee] = (data[:gas] * data[:gas_price]).to_eth

        return unless (data[:block_number].to_i(16) rescue nil)

        block ||= block_details(data[:block_number].to_i(16))

        data[:block_number] = data[:block_number].to_i(16)
        data[:timestamp] = Time.at(block[:timestamp].to_i(16))
      end

      def block_details(block_number)
        full_transaction_objects = true
        request(
          :eth_getBlockByNumber, block_number, full_transaction_objects
        )
      end

      def format_address(address)
        Eth::Utils.format_address(address)
      end

      def request(web3_method, *args)
        Retriable.retriable(
          tries: 10, max_elapsed_time: 1.minute,
          on: [Net::OpenTimeout, Net::ReadTimeout, JSON::ParserError]
        ) {
          response = client.send_command(web3_method, args.presence || [])
          return nil if response['result'].nil?

          response['result'].underscore_keys! if response['result'].is_a?(Hash)
          response['result']
        }
      end

      def client
        @_client = ::Ethereum::HttpClient.new(endpoint)
      end

      def endpoint
        [Rails.application.credentials.blockchains.ethereum.endpoint, port].
          compact.join(':')
      end

      def port
        if Rails.env.development?
          7545
        elsif Rails.env.test?
          7546
        end
      end
    end
  end
end
