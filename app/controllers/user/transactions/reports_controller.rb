class User::Transactions::ReportsController < ApplicationController
  before_action :require_authentication, :require_level_1

  def download
    report = Reports::Accounts::Transactions.execute!(
      account: current_user.account
    )
    send_data report.to_stream.read,
      type: 'application/xlsx',
      filename: Reports::Accounts::Transactions::FILE_NAME
  end
end
