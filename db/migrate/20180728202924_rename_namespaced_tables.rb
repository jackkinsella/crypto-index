class RenameNamespacedTables < ActiveRecord::Migration[5.2]
  def change
    [
      'currency/transactions',
      'user/portfolio/compositions',
      'user/passports',
      'user/sessions',
      'user/postal_addresses',
      'user/portfolios',
      'user/accounts',
      'user/account/deposits',
      'currency/addresses',
      'index/allocations',
      'index/components',
      'valuation/readings',
      'user/holdings',
      'market/trades',
      'user/account/withdrawals',
      'user/portfolio/rebalancings'
    ].each do |new_table_name|
      old_table_name = new_table_name.gsub('/', '_')
      rename_table old_table_name, new_table_name
    end
  end
end
