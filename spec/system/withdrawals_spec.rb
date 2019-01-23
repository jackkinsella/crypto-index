require 'rails_helper'

RSpec.describe 'Withdrawals' do
  fixtures :all

  let(:user) { users(:deposited) }
  let(:index) { Index.market10 }
  let(:portfolio) { user.portfolio }

  before { Timecop.freeze(Fixtures::REBALANCING_TIMESTAMP) }

  # TODO: Test re-entrancy/ idempotency (possibly in unit tests instead) :
  # It should never be possible for our schedulers or malicious users to request
  # more withdrawals than possible - this is a common way exchanges get hacked!
  #
  # TODO: Test path where false confirmation link attempted

  it 'works' do
    # TODO: Test that the user entered their own deposit address
    #
    # FIXME: This step should be triggered through the UI by the user
    Accounts::Withdrawals::Request.execute!(account: user.account)

    # it 'sends an email requesting withdrawal'
    withdrawal_requested_email = ActionMailer::Base.deliveries.last
    expect(withdrawal_requested_email.subject).
      to match(/Please confirm withdrawal request/)

    # it 'lets user confirm their withdrawal request'
    confirmation_link = links_in_email(withdrawal_requested_email).
      find { |link| link.match(/confirm/) }
    visit confirmation_link
    log_in(user: user)

    # it 'shows flash message clarifying to the user that the withdrawal request
    # was confirmed'
    expect(find('.notification.is-success')).to have_text(
      'Withdrawal request confirmed!'
    )

    # TODO: Write remainder of test as soon as withdrawal features are completed
  end
end
