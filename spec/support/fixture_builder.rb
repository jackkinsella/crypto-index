require Rails.root.join('spec/support/fixtures')
require Rails.root.join('spec/support/blockchains/accounts')

require_relative 'factory_bot/strategy'

FixtureBuilder.configure do |builder|
  include Blockchains::Accounts

  def build_currency_fixtures
    CSV.read_config_data(:currencies).select { |data|
      Fixtures::CURRENCY_SYMBOLS.include?(data['symbol'])
    }.each do |data|
      FactoryBot.create(:currency, **data.to_h.symbolize_keys)
    end
  end

  def provide_unchanging_record_ids!
    ActiveRecord::Base.connection.tables.each do |table|
      ActiveRecord::Base.connection.reset_pk_sequence!(table)
    end
  end

  def build_valuation_fixture(currency:, timestamp:)
    price_usd = Fixtures.price_for(currency.symbol, timestamp)
    circulating_supply = Fixtures.circulating_supply_for(
      currency.symbol, timestamp
    )
    market_cap_usd = price_usd * circulating_supply

    valuation_reading = FactoryBot.build(
      :valuation_reading,
      source_name: :coin_market_cap,
      currency: currency,
      market_cap_usd: market_cap_usd,
      price_usd: price_usd.to_d,
      circulating_supply: circulating_supply.to_d,
      timestamp: timestamp
    )

    FactoryBot.create(
      :valuation,
      currency: currency,
      readings: [valuation_reading],
      timestamp: timestamp
    )
  end

  def build_valuation_fixtures_for_time_range(
    start_time:, end_time:, currencies:
  )
    currencies.order(symbol: :desc).each do |currency|
      end_time = end_time

      Time.partition(start_time, end_time).each do |time|
        build_valuation_fixture(
          currency: currency,
          timestamp: time
        )
      end
    end
  end

  def build_genesis_valuation_fixtures
    currencies = Currency.where(
      symbol: Fixtures::CURRENCY_SYMBOLS_IN_M10_AT[:genesis]
    )
    end_time = CryptoIndex::GENESIS_DATE.to_time
    start_time = end_time - 24.hours

    build_valuation_fixtures_for_time_range(
      start_time: start_time,
      end_time: end_time,
      currencies: currencies
    )
  end

  def build_default_timestamp_valuation_fixtures
    currencies = Currency.available_at(Fixtures::DEFAULT_TIMESTAMP)

    start_time = Fixtures::DEFAULT_TIMESTAMP - 24.hours
    end_time = Fixtures::DEFAULT_TIMESTAMP + Fixtures::DEFAULT_DURATION

    build_valuation_fixtures_for_time_range(
      start_time: start_time,
      end_time: end_time,
      currencies: currencies
    )
  end

  def build_rebalancing_timestamp_valuation_fixtures
    currencies = Currency.available_at(Fixtures::REBALANCING_TIMESTAMP)

    start_time = Fixtures::REBALANCING_TIMESTAMP - 24.hours
    end_time = Fixtures::REBALANCING_TIMESTAMP

    build_valuation_fixtures_for_time_range(
      start_time: start_time,
      end_time: end_time,
      currencies: currencies
    )
  end

  def build_valuation_fixtures_that_are_not_allocated_to_indexes
    currencies = Currency.available_at(Fixtures::UNALLOCATED_TIMESTAMP)

    start_time = Fixtures::UNALLOCATED_TIMESTAMP - 24.hours
    end_time = Fixtures::UNALLOCATED_TIMESTAMP

    build_valuation_fixtures_for_time_range(
      start_time: start_time,
      end_time: end_time,
      currencies: currencies
    )
  end

  def build_indexes
    CSV.read_config_data(:indexes).each do |data|
      # FIXME: Remove the following line as soon as M10E is compatible with
      # deposit/rebalancing code and stops throwing NotImplementedError.
      next if data.to_h['symbol'] == 'M10E'
      FactoryBot.create(:index, **data.to_h.symbolize_keys)
    end
  end

  def build_markets
    CSV.read_config_data(:markets).each do |data|
      FactoryBot.create(:market, **data.to_h.symbolize_keys)
    end
  end

  def build_users
    CSV.read_config_data(:'users.test').each do |data|
      user = FactoryBot.create(
        :user, **data.to_h.symbolize_keys.slice(
          :email, :password, :phone, :first_name, :last_name
        )
      )
      user.update!(
        email_confirmed_at: Time.now,
        phone_confirmed_at: Time.now
      )
      user.create_postal_address!(
        **data.to_h.symbolize_keys.slice(
          :street_line_1, :street_line_2, :zip_code, :city,
          :region, :country_alpha2_code
        )
      )

      user.account.addresses.deposit.generate_for!(
        owner: user.account,
        currency: Currency.eth,
        category: :deposit
      )
    end
  end

  def build_allocations
    Allocations::Create.execute!(
      from_date: CryptoIndex::GENESIS_DATE,
      to_date: Time.now
    )
  end

  def build_deposits(user, value: 100.to_d)
    user_ethereum_account = ethereum_accounts.send(name_for_user(user))
    deposit_address = user.account.addresses.deposit.take

    time_needed_for_assessment_to_notice_deposit = 1.second

    deposit = User::Account::Deposit.create(
      user_account: user.account,
      currency: Currency.eth,
      amount: value,
      crypto_index_fee: 1.to_d,
      received_at: Fixtures::DEFAULT_TIMESTAMP -
        time_needed_for_assessment_to_notice_deposit
    )

    from_address = Currency::Address.new(
      currency: Currency.eth,
      category: :user_inbound,
      owner: user,
      value: user_ethereum_account.address
    )
    build_transaction(
      sender: user,
      receiver: deposit,
      value: value,
      from_address: from_address,
      to_address: deposit_address
    )
    deposit
  end

  # rubocop:disable Metrics/ParameterLists
  def build_transaction(
    sender:, receiver:, value:, from_address:, to_address:,
    currency: Currency.eth, nonce: 0
  )

    Currency::Transaction.create!(
      sender: sender,
      receiver: receiver,
      currency: currency,
      value: value,
      nonce: nonce,
      from_address: from_address,
      to_address: to_address
    )
  end
  # rubocop:enable Metrics/ParameterLists

  def build_deposit_with_trades
    deposited = User.find_by(email: 'deposited@example.com')
    rebalanced = User.find_by(email: 'rebalanced@example.com')

    [deposited, rebalanced].each do |user|
      deposit = build_deposits(user)

      relayed_transaction = build_transaction(
        sender: deposit,
        receiver: Market.binance,
        value: deposit.amount,
        from_address: deposit.account.addresses.last,
        to_address: Market.binance.inbound_address
      )

      deposit.update!(
        relayed_transaction: relayed_transaction,
        relayed_at: Fixtures::DEFAULT_TIMESTAMP
      )

      deposit.trades = Trading::Assembly::Deposit.execute!(
        deposit: deposit,
        index: Index.m10
      ).tap do |trades|
        trades.each do |trade|
          Trading::Orders::Create.execute!(trade: trade)
        end
      end

      Accounts::Deposits::Finalize.execute!(deposits: deposit)

      Portfolios::Update.execute!(trades: deposit.trades)
    end
  end

  def build_rebalancings_with_trades
    rebalanced = User.find_by(email: 'rebalanced@example.com')

    [rebalanced].each do |user|
      portfolio = user.portfolio
      Portfolios::Rebalancings::Request.execute!(portfolio: portfolio)
      rebalancing = portfolio.rebalancings.take

      Timecop.freeze(Fixtures::REBALANCING_TIMESTAMP) do
        build_compositions

        Portfolios::Rebalancings::Realize.execute!(
          rebalancings: rebalancing
        )
        rebalancing.trades.each do |trade|
          Trading::Orders::Create.execute!(trade: trade)
        end

        Portfolios::Rebalancings::Finalize.execute!(
          rebalancings: rebalancing
        )
      end
    end
  end

  def build_compositions
    User::Portfolio.order(:id).each do |portfolio|
      Compositions::Create.execute!(portfolio: portfolio)
    end
  end

  def name_for_user(user)
    email = user.respond_to?(:email) ? user.email : user['email']
    email.split('@').first.underscore
  end

  builder.files_to_check += Dir[
    'app/**/*.rb',
    'config/data/**/*.csv',
    'spec/factories/**/*.rb',
    'spec/support/fixture_builder.rb',
    'spec/support/fixtures.rb'
  ]

  builder.skip_tables += ['ar_internal_metadata']

  builder.name_model_with(Currency) do |record|
    record['symbol'].downcase
  end

  builder.name_model_with(Index) do |record|
    record['name']
  end

  builder.name_model_with(Index::Allocation) do |record|
    index_name = Index.find(record['index_id']).name

    "allocation_for_#{index_name}_at_#{record['timestamp'].to_i}"
  end

  builder.name_model_with(Index::Component) do |record|
    allocation = Index::Allocation.find(record['allocation_id'])
    index_name = allocation.index.name
    symbol = Currency.find(record['currency_id']).symbol.downcase
    timestamp = allocation.timestamp.to_i
    "#{symbol}_component_for_#{index_name}_at_#{timestamp}"
  end

  builder.name_model_with(Market) do |record|
    record['name']
  end

  builder.name_model_with(User) do |record|
    name_for_user(record)
  end

  builder.name_model_with(User::Account) do |record|
    user = User.find(record['user_id'])
    "account_for_#{name_for_user(user)}"
  end

  builder.name_model_with(User::PostalAddress) do |record|
    user = User.find(record['user_id'])
    "postal_address_for_#{name_for_user(user)}"
  end

  builder.name_model_with(User::Portfolio) do |record|
    user = User.find(record['user_id'])
    "portfolio_for_#{name_for_user(user)}"
  end

  builder.name_model_with(User::Portfolio::Composition) do |record|
    user = User::Portfolio.find(record['portfolio_id']).user
    "user_portfolio_composition_for_#{name_for_user(user)}_at_" \
    "#{record['timestamp'].to_i}"
  end

  builder.name_model_with(Valuation) do |record|
    currency = Currency.find(record['currency_id'])
    "#{currency.symbol.downcase}_valuation_at_#{record['timestamp'].to_i}"
  end

  builder.name_model_with(Valuation::Reading) do |record|
    currency = Currency.find(record['currency_id'])
    "#{currency.symbol.downcase}_valuation_reading_from_" \
    "#{record['source_name']}_at_#{record['timestamp'].to_i}"
  end

  builder.factory do
    provide_unchanging_record_ids!

    unchanging_created_at =
      Fixtures::REBALANCING_TIMESTAMP + Valuation::RECENT_INTERVAL

    Timecop.freeze(unchanging_created_at)

    build_currency_fixtures
    build_genesis_valuation_fixtures
    build_default_timestamp_valuation_fixtures
    build_rebalancing_timestamp_valuation_fixtures
    build_indexes
    build_markets
    build_users

    Valuation::Indicator.refresh

    build_allocations

    Timecop.freeze(Fixtures::DEFAULT_TIMESTAMP)
    build_deposit_with_trades

    Timecop.freeze(Fixtures::DEFAULT_TIMESTAMP + Fixtures::DEFAULT_DURATION)

    build_rebalancings_with_trades
    build_compositions

    Timecop.freeze(Fixtures::UNALLOCATED_TIMESTAMP + Valuation::RECENT_INTERVAL)
    build_valuation_fixtures_that_are_not_allocated_to_indexes

    Timecop.return
  end
end
