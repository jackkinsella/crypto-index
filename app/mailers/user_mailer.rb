class UserMailer < ApplicationMailer
  default(
    from: 'CryptoIndex <updates@example.com>',
    template_path: 'emails/user'
  )

  def signed_up(user)
    @user = user
    mail to: @user.email, subject: 'Welcome to CryptoIndex'
  end

  def account_set_up(user)
    @user = user
    mail to: @user.email, subject: 'Your account is ready to fund!'
  end

  def deposit_received(deposit)
    @deposit = deposit
    @user = deposit.user

    mail to: @user.email, subject: 'We received your deposit of ' \
      "#{@deposit.amount} #{@deposit.currency.symbol}"
  end

  def portfolio_ready(portfolio)
    @portfolio = portfolio
    @user = portfolio.user

    mail to: @user.email, subject: 'Your new portfolio has been assembled'
  end

  def portfolio_rebalanced(rebalancing)
    @rebalancing = rebalancing
    @user = rebalancing.user

    mail to: @user.email, subject: 'Your portfolio has been rebalanced'
  end

  def withdrawal_requested(withdrawal)
    @withdrawal = withdrawal
    @user = withdrawal.user

    mail to: @user.email, subject: 'Please confirm withdrawal request'
  end
end
