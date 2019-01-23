require 'rails_helper'

RSpec.describe 'Login' do
  fixtures :users, :'user/portfolios', :'user/postal_addresses'

  let(:correct_password) { 'password' }
  let(:user) { users(:signed_up) }

  context 'when the user visits the login page directly' do
    before {
      log_in(user: user, password: password)
    }

    context 'given the correct password' do
      let(:password) { correct_password }

      it 'allows the user to log in' do
        expect(current_path).to eq(account_dashboard_path)

        # it 'sets the user properties in localstorage'
        freshchat_props = JSON.parse(
          page.evaluate_script("window.localStorage.getItem('freshchat')")
        )
        expect(freshchat_props['email']).to eq(user.email)
      end
    end

    context 'given an incorrect password', ignore_js_error: /401/ do
      let(:password) { 'incorrect' }

      it 'does not allow the user to log in' do
        expect(current_path).to eq(login_path)
      end

      it 'allows the user to try again' do
        log_in(user: user, password: correct_password)
        expect(current_path).to eq(account_dashboard_path)
      end
    end
  end

  context 'when the user wants to access a page behind a login wall' do
    let(:path) { transactions_withdrawals_path }

    it 'redirects back to the original page after login' do
      visit path
      log_in(user: user, password: correct_password) and wait
      expect(current_path).to eq(path)
    end
  end

  context 'when the user is already logged in' do
    before {
      log_in(user: user, password: correct_password)
    }

    it 'allows them to log out' do
      click_on 'Log out'
      visit account_path
      expect(current_path).to eq(login_path)
    end
  end
end
