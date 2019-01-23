module Blockchains
  module Accounts
    extend ActiveSupport::Concern

    included do
      def ethereum_accounts
        @_ethereum_accounts ||= CSV.read(
          "#{Rails.root}/config/data/blockchains/ganache/accounts.csv",
          skip_lines: /^#/, headers: true
        ).each_with_object(OpenStruct.new) { |row, memo|
          memo[row['name']] = row.to_h.to_open_struct
        }
      end
    end
  end
end
