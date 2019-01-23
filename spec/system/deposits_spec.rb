require 'rails_helper'

# FIXME: This test needs to be updated to properly access whether fees are
# correctly charged and turned into BNB etc.

RSpec.describe 'Deposits', :ethereum do
  fixtures :all

  let(:timestamp) { Fixtures::DEFAULT_TIMESTAMP }
  let(:deposit_value) { 5.eth }
  let(:user) { users(:signed_up) }

  before {
    log_in(user: user)
    Timecop.travel(timestamp)
  }

  context 'inside "Transactions" > "Deposits"' do
    let(:deposit_address) { user.account.addresses.deposit.take }

    before {
      visit transactions_deposits_path
    }

    it 'shows the current deposit address' do
      expect(deposit_address).not_to be_nil
      expect(page).to have_content(deposit_address.to_s)
    end

    context 'given a new deposit' do
      before {
        Blockchains::Ethereum::Network.send_transaction(
          private_key: user_ethereum_account.private_key,
          from_address: user_ethereum_account.address,
          to_address: deposit_address,
          nonce: 0,
          value: deposit_value
        ) and mine

        # FIXME: These should be triggered with the scheduler
        Accounts::Deposits::TrackJob.perform_now
        Accounts::Deposits::FinalizeJob.perform_now

        visit current_path
      }

      let(:user_ethereum_account) { ethereum_accounts.visitor }
      let(:deposit) { user.deposits.take }

      context 'given a deposit below the minimum deposit amount' do
        let(:deposit_value) { 0.5.eth }

        it 'ignores the deposit' do
          expect(user.deposits.count).to be(0)
        end
      end

      context 'given a deposit above the maximum deposit amount for Level 1' do
        let(:deposit_value) { 10.5.eth }

        it 'ignores the deposit' do
          expect(user.deposits.count).to be(0)
        end
      end

      it 'creates exactly one deposit' do
        expect(user.deposits.count).to be(1)

        # it 'shows the new deposit'
        expect(page).to have_content(deposit_value)

        # it 'tracks the user correctly as the sender'
        expect(deposit.received_transaction.sender).to eq(user)

        # it 'relays the deposit'
        expect(deposit.relayed?).to be(true)

        # it 'sends the deposit to Binance'
        expect(deposit.relayed_transaction.receiver).to eq(markets(:binance))

        # FIXME: The rest essentially tests trading as well.
        # Of course, this needs to be split out and refactored.
        #
        expect(
          [Currency::Address.where(owner: user).count,
           Currency::Address.where(owner: user.account).count].sum
        ).to be(2)

        expect(deposit.trades.user.count).to be(9)
        expect(deposit.trades.service.count).to be(1)

        expect(deposit.trades.user.pluck(:symbol).sort).to eq(
          Fixtures::CURRENCY_SYMBOLS_IN_M10_AT[:default_timestamp].sort.
          map { |symbol|
            if symbol == 'BTC'
              'ETHBTC'
            elsif symbol == 'ETH'
              nil
            else
              "#{symbol}ETH"
            end
          }.compact
        )

        # it 'sets takes the crypto_index fee in BNB'
        fudge_factor = deposit_value / 3000
        service_trade = deposit.trades.service.find_by(symbol: 'BNBETH')
        expect(service_trade.from_amount).to be_within(fudge_factor).
          of(deposit_value * 0.01)

        # it 'sets the deposit net amount correctly'
        expect(deposit.net_amount).to be_within(fudge_factor).
          of(deposit_value * 0.99)

        expect(
          deposit.trades.find_by!(symbol: 'ETHBTC').order_side
        ).to eq('SELL')

        expect(
          deposit.trades.where.not(symbol: 'ETHBTC').pluck(:order_side).uniq
        ).to eq(['BUY'])

        expect(
          deposit.trades.pluck(:order_type).uniq
        ).to eq(['MARKET'])

        expect(
          deposit.trades.all.map(&:started?).uniq
        ).to eq([true])

        expect(
          deposit.trades.all.map(&:completed?).uniq
        ).to eq([true])

        expect(
          deposit.trades.pluck(:details).reject(&:empty?).size
        ).to be(10)

        expect(user.holdings.count).to be(10)

        expect(user.holdings.all.map(&:symbol).sort).to eq(
          Fixtures::CURRENCY_SYMBOLS_IN_M10_AT[:default_timestamp].sort
        )

        # it 'gets the holdings (and by extension, trades) correct when
        # _buying_'
        expect(
          user.holdings.where(currency: Currency.ada).take.size
        ).to be_within(0.1).percent_of(
          (Index.m10.components.where(currency: Currency.ada).take.weight *
          Fixtures.exchange_rate('ETH', 'ADA') *
          deposit_value * 0.99)
        )

        # it 'gets the holdings (and by extension, trades) right when _selling_'
        expect(
          user.holdings.where(currency: Currency.btc).take.size
        ).to be_within(0.1).percent_of(
          (Index.m10.components.where(currency: Currency.btc).take.weight *
          Fixtures.exchange_rate('ETH', 'BTC') *
          deposit_value * 0.99
          )
        )

        # it 'gets the holdings right for the base currency used for deposit'
        expect(
          user.holdings.where(currency: Currency.eth).take.size
        ).to be_within(0.4).percent_of(
          (Index.m10.components.where(currency: Currency.eth).take.weight *
           deposit_value * 0.99
          )
        )

        # == UI assertions ==

        # it shows the holdings in /portfolio/currencies
        click_link 'Currencies'
        btc_holding_text = find('tr#BTC td:nth-of-type(3)').text
        expect(btc_holding_text.extract_d).to eq(
          user.holdings.where(currency: Currency.btc).take.size.round(2)
        )

        # it shows the tracked indexes in /portfolio/indexes
        click_link 'Indexes'
        market10_percent_text = find('tr#M10 td:nth-of-type(3)').text
        expect(market10_percent_text).to eq('100%')

        # it 'sends the appropriate emails'
        deposit_email, portfolio_ready_email =
          ActionMailer::Base.deliveries.last(2)
        expect(deposit_email.subject).to match(/We received your deposit/)
        expect(portfolio_ready_email.subject).
          to match(/portfolio has been assembled/)
      end
    end
  end
end
