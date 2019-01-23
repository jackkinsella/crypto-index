class User::Transactions::RebalancingsController < ApplicationController
  before_action :require_authentication, :require_level_1

  def index
    # FIXME: Once the front-end is refactored enough to display detailed info
    # about each rebalancing (e.g. whether it has been finalized or not), the
    # @rebalancings variable should no longer be scoped to `finalized`
    @rebalancings = current_user.rebalancings.
      finalized.order(scheduled_at: :desc).to_a
  end
end
