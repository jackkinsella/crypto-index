module Blockchains
  module DeterministicWallet
    class Derive < ApplicationAction
      def initialize(extended_key:, key_path:)
        @extended_key = extended_key
        @key_path = key_path

        raise ArgumentError if key_path.blank?
      end

      def execute!
        {
          bitcoin_address: node.to_address,
          ethereum_address: ethereum_address,
          private_key: (private_key if extended_private_key?),
          public_key: public_key
        }.to_open_struct
      end

      private

      attr_reader :extended_key, :key_path

      def extended_private_key?
        extended_key.start_with?('xprv')
      end

      def private_key
        node.private_key&.to_hex
      end

      def public_key
        node.public_key.to_hex
      end

      def ethereum_address
        Eth::Utils.public_key_to_address(node.public_key.uncompressed.to_hex)
      end

      def node
        @_node ||=
          MoneyTree::Node.from_bip32(extended_key).node_for_path(key_path)
      end
    end
  end
end
