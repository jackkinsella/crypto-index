require 'rails_helper'

RSpec.describe 'Rebalancings' do
  fixtures :all

  let(:user) { users(:deposited) }
  let(:requested_at_timestamp) {
    expected_rebalancing_scheduled_at - 3.weeks - 1.day
  }
  let(:fee_multiplier) { 0.999 }
  let(:index) { Index.market10 }
  let(:portfolio) { user.portfolio }
  let(:deposit) { user.portfolio.deposits.take }
  let(:expected_rebalancing_scheduled_at) {
    Fixtures::REBALANCING_TIMESTAMP
  }

  it 'works' do
    initial_btc_holding_size =
      user.holdings.where(currency: Currency.btc).last.size
    Timecop.freeze(requested_at_timestamp)

    # FIXME: This should be triggered with the scheduler to ensure that the
    # automatic triggering is tested. E.g. Perhaps there could be a `tick`
    # method that runs the scheduler.
    Portfolios::Rebalancings::Request.execute!(portfolio: portfolio)

    # it 'schedules the rebalancing job'
    first_rebalancing = portfolio.rebalancings.where(
      finalized_at: nil, scheduled_at: expected_rebalancing_scheduled_at
    )
    expect(first_rebalancing.exists?).to be(true)

    Timecop.freeze(expected_rebalancing_scheduled_at)

    # FIXME: This should be triggered with the scheduler
    Portfolios::Rebalancings::Realize.execute!(rebalancings: first_rebalancing)

    # FIXME: This should be triggered with the scheduler
    Portfolios::Rebalancings::Finalize.execute!(
      rebalancings: first_rebalancing
    )

    Timecop.freeze(Time.now + User::Portfolio::Composition::WAIT_INTERVAL)
    # FIXME: This should be triggered with the scheduler
    Compositions::Create.execute!(portfolio: portfolio)
    expect(user.portfolio.compositions.maximum(:timestamp)).to be >=
      first_rebalancing.take.finalized_at

    # it 'correctly charges the rebalancing fee'
    service_trade = first_rebalancing.take.trades.service.take
    expect(service_trade.from_amount).to be_within(0.1).
      percent_of(portfolio.value_eth * 0.001)

    # it 'updates the UI in /portfolio/rebalancings'
    log_in(user: user)
    click_link 'Rebalancings'
    table = find('table')
    expect(table.all('tr').count).to eq(1)
    expect(table).to have_text('about 1 hour ago')

    # it 'updates the UI in /portfolio/currencies'
    click_link 'Currencies'
    btc_holding_text = find('tr#BTC td:nth-of-type(3)').text
    expect(btc_holding_text.extract_d).to eq(
      user.reload.holdings.where(currency: Currency.btc).take.size.round(2)
    )

    # it 'sets the correct holding for BTC'
    original_allocation =
      index.allocations.at(deposit.finalized_at).take
    new_allocation =
      index.allocations.at(first_rebalancing.take.finalized_at).take
    index_value_change =
      new_allocation.value / original_allocation.value
    btc_market_cap_change =
      Fixtures.market_cap_for('BTC') /
      Fixtures.market_cap_for('BTC', deposit.finalized_at)

    expected_btc_holding = initial_btc_holding_size *
      index_value_change / btc_market_cap_change * fee_multiplier

    expect(user.reload.holdings.where(currency: Currency.btc).take.size).
      to be_within(0.5).percent_of(expected_btc_holding)

    # it 'sends an email to the user about the rebalancing'
    rebalancing_email = ActionMailer::Base.deliveries.last
    expect(rebalancing_email.subject).
      to match(/Your portfolio has been rebalanced/)

    # it "schedules the next rebalancing in month's time, no sooner"
    # FIXME: This should be triggered with the scheduler
    Portfolios::Rebalancings::Request.execute!(portfolio: portfolio)

    next_rebalancing = portfolio.rebalancings.where(finalized_at: nil).
      order(:scheduled_at).last
    expect(next_rebalancing.scheduled_at).to eq(
      first_rebalancing.take.scheduled_at + 1.month
    )
  end
end
