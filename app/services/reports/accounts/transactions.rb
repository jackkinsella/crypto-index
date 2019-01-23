module Reports
  module Accounts
    class Transactions < ApplicationAction
      FILE_NAME = 'crypto_index-transactions.xlsx'.freeze

      def initialize(account:)
        @deposits = account.deposits
        @trades = account.completed_trades
        @withdrawals = account.withdrawals.finalized
        @balances = Hash.new(0)
      end

      # TODO: Handle airdrops
      # TODO: Handle forks
      def execute!
        rows = []

        [deposits, trades, withdrawals].flatten.sort_by { |record|
          chronological_sorting_key(record)
        }.each do |record|
          case record
          when User::Account::Deposit
            rows << add_deposit_row(record)
          when User::Account::Withdrawal
            rows << add_withdrawal_row(record)
          when Market::Trade
            rows << (if record.category.to_sym == :user
                       add_trade_row(record)
                     elsif record.category.to_sym == :service
                       add_fee_row(record)
                     end)
          end
        end
        generate_spreadsheet(rows)
      end

      private

      def chronological_sorting_key(record)
        case record
        when User::Account::Deposit
          record.received_at
        when User::Account::Withdrawal
          record.finalized_at
        when Market::Trade
          record.completed_at
        end
      end

      def add_deposit_row(deposit)
        balances[deposit.currency.symbol.to_sym] += deposit.amount

        build_row(
          id: "dep_#{deposit.external_id}",
          time: deposit.received_at,
          type: 'Deposit',
          base_currency: deposit.currency,
          amount: deposit.amount
        )
      end

      # FIXME: Untested pending availability of fixture data for withdrawals
      def add_withdrawal_row(withdrawal)
        balances[withdrawal.currency.symbol.to_sym] -= withdrawal.amount

        build_row(
          id: "wit_#{withdrawal.external_id}",
          time: withdrawal.finalized_at.round_down,
          type: 'Withdrawal',
          base_currency: withdrawal.currency,
          amount: -withdrawal.net_amount
        )
      end

      def add_trade_row(trade)
        balances[trade.from_currency.symbol.to_sym] -= trade.from_amount
        balances[trade.to_currency.symbol.to_sym] += trade.to_amount

        price_usd_of_base_currency = trade.base_currency.price_usd_at(
          chronological_sorting_key(trade)
        )

        price_usd_of_quote_currency = trade.quote_currency.price_usd_at(
          chronological_sorting_key(trade)
        )

        build_row(
          id: "trd_#{trade.external_id}",
          time: trade.completed_at,
          type: 'Trade',
          base_currency: trade.base_currency,
          quote_currency: trade.quote_currency,
          pair: trade.symbol,
          side: trade.order_side,
          amount: trade.amount,
          price: trade.price,
          total_cost: trade.cost,
          total_cost_usd: trade.cost * price_usd_of_quote_currency,
          price_usd_of_base_currency: price_usd_of_base_currency,
          price_usd_of_quote_currency: price_usd_of_quote_currency
        )
      end

      def add_fee_row(trade)
        balances[trade.from_currency.symbol.to_sym] -= trade.from_amount

        price_usd_of_base_currency = trade.base_currency.price_usd_at(
          trade.completed_at
        )

        build_row(
          id: "fee_#{trade.initiator.external_id}",
          time: trade.completed_at,
          type: "#{trade.initiator.class.name.demodulize} Fee",
          base_currency: trade.quote_currency,
          amount: trade.cost,
          total_cost: trade.cost,
          total_cost_usd: price_usd_of_base_currency * trade.amount
        )
      end

      def generate_spreadsheet(rows)
        Axlsx::Package.new do |package|
          package.workbook.add_worksheet(name: 'Detailed view') do |sheet|
            headers = (rows.first&.keys || []).map { |key|
              if all_currencies_ever_in_portfolio.include?(key)
                "#{key} Balance"
              else
                key.to_s.titlecase
              end
            }
            sheet.add_row(headers)
            rows.map do |row|
              sheet.add_row(row.values)
            end
          end
          package.use_shared_strings = true
        end
      end

      def build_row(overrides)
        {
          id: nil,
          time: nil,
          type: nil,
          base_currency: nil,
          quote_currency: nil,
          pair: nil,
          side: nil,
          amount: nil,
          price: nil,
          total_cost: nil,
          total_cost_usd: nil,
          price_usd_of_base_currency: nil,
          price_usd_of_quote_currency: nil
        }.merge(
          Hash[all_currencies_ever_in_portfolio.zip([nil])].merge(balances)
        ).merge(overrides)
      end

      def all_currencies_ever_in_portfolio
        (deposits.map(&:currency) +
         trades.reject(&:service?).map(&:to_currency) +
         withdrawals.map(&:currency)
        ).uniq.map(&:symbol).map(&:to_sym)
      end

      attr_accessor :deposits, :trades, :withdrawals, :balances
    end
  end
end
