module Blockchains
  module Mining
    extend ActiveSupport::Concern

    included do
      delegate :mine, to: :ganache

      def ethereum_accounts
        @_ethereum_accounts ||= CSV.read(
          "#{Rails.root}/config/data/blockchains/ganache/accounts.csv",
          skip_lines: /^#/, headers: true
        ).each_with_object(OpenStruct.new) { |row, memo|
          memo[row['name']] = row.to_h.to_open_struct
        }
      end

      around(:each, :ethereum) do |example|
        ganache.take_snapshot
        example.run
        ganache.revert_to_snapshot('0x01')
      end

      before(:each, :ethereum) do
        ganache.disable_automining

        allow_any_instance_of(Transactions::ConfirmJob).to receive(:retry_job).
          and_wrap_original { |method, *args| mine && method.call(*args) }
      end
    end

    class Ganache < Blockchains::Ethereum::Network
      def take_snapshot
        request(:evm_snapshot)
      end

      def revert_to_snapshot(snapshot_id)
        request(:evm_revert, [snapshot_id])
      end

      def disable_automining
        request(:miner_stop)
      end

      def mine(number_of_blocks = 10)
        number_of_blocks.times { request(:evm_mine) }
      end
    end

    private

    def ganache
      @ganache ||= Ganache.new
    end
  end
end
