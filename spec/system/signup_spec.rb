require 'rails_helper'

RSpec.describe 'Signup' do
  fixtures :currencies, :users

  american_ip_address = '47.206.51.67'
  swiss_ip_address = '85.195.243.10'

  let(:new_email) { 'john@example.com' }
  let(:signed_up_user) { users(:signed_up) }
  let(:email) { new_email }

  let(:valid_phone_country_code) { '49' }
  let(:valid_phone_number) { '15724548918' }
  let(:phone_country_code) { valid_phone_country_code }
  let(:phone_number) { valid_phone_number }
  let(:first_name) { 'John' }
  let(:last_name) { 'Doe' }
  let(:street_line_1) { '14 Ladbroke Terrace' }
  let(:street_line_2) { nil }
  let(:zip_code) { 'W11 3PG' }
  let(:city) { 'London' }
  let(:country_alpha2_code) {
    'United Kingdom of Great Britain and Northern Ireland'
  }

  def last_user
    User.order(:created_at).last
  end

  def fill_in_email
    visit home_path
    fill_in 'user[email]', with: email, match: :first
    find('[type="submit"]', match: :first).click and wait
  end

  def confirm_email
    visit links_in_email(last_email).find { |link| link.match(/confirm/) }
  end

  def fill_in_password
    within('.setup') do
      fill_in 'user[password]', with: 'password'
      find('[type="submit"]').click and wait
    end
  end

  def fill_in_phone_number
    within('.setup') do
      fill_in 'user[phone_number]', with: phone_number
      select phone_country_code, from: 'user[phone_country_code]'
      find('[type="submit"]').click and wait
    end
  end

  def fill_in_name_and_address
    within('.setup') do
      fill_in 'user[first_name]', with: first_name
      fill_in 'user[last_name]', with: last_name
      fill_in 'postal_address[street_line_1]', with: street_line_1
      fill_in 'postal_address[street_line_2]', with: street_line_2
      fill_in 'postal_address[zip_code]', with: zip_code
      fill_in 'postal_address[city]', with: city
      select country_alpha2_code, from: 'postal_address[country_alpha2_code]'
      find('[type="submit"]').click and wait
    end
  end

  def confirm_phone_with_code(code = phone_confirmation_code)
    within('.setup') do
      fill_in 'user[phone_confirmation_code]', with: code
      find('[type="submit"]').click and wait
    end
  end

  def complete_sign_up_steps(to_step:)
    steps = [
      :fill_in_email,
      :confirm_email,
      :fill_in_password,
      :fill_in_phone_number,
      :confirm_phone_with_code,
      :fill_in_name_and_address
    ]
    steps[0..steps.index(to_step)].map { |method| send(method) }
  end

  def log_out
    visit logout_path
  end

  def expect_to_be_at_step(number)
    within('.setup') do
      expect(page).to have_css(".step-#{number}")
    end
  end

  def expect_to_see_error(message)
    within('#error-messages') do
      expect(page).to have_text(message)
    end
  end

  before {
    stub_request_with_recording(
      :get, 'https://www.sanctions.io/search/?sname=John%20Doe'
    )
    stub_request_with_recording(
      :get, 'https://www.sanctions.io/search/?sname=Bashar%20al-Assad'
    )
    stub_request_with_recording(
      :get,
      'https://maps.googleapis.com/maps/api/geocode/json?address=14%20Ladbroke%20Terrace,%20,%20W11%203PG,%20London,%20,%20United%20Kingdom%20of%20Great%20Britain%20and%20Northern%20Ireland&components=admistrative_area:London%7Croute:14%20Ladbroke%20Terrace,%20&key=AIzaSyBna9ckRdY18Xacie2vKknvXk5CskVBbZ8'
    )
    stub_request_with_recording(
      :get,
      'https://maps.googleapis.com/maps/api/geocode/json?address=4000%20Fake%20Street,%20,%20W11%203PG,%20London,%20,%20United%20Kingdom%20of%20Great%20Britain%20and%20Northern%20Ireland&components=admistrative_area:London%7Croute:4000%20Fake%20Street,%20&key=AIzaSyBna9ckRdY18Xacie2vKknvXk5CskVBbZ8'
    )
    stub_request_with_recording(
      :get,
      'https://maps.googleapis.com/maps/api/geocode/json?address=14%20Ladbroke%20Terrace,%20,%20W11%203PG,%20London,%20,%20United%20States%20of%20America&components=admistrative_area:London%7Croute:14%20Ladbroke%20Terrace,%20&key=AIzaSyBna9ckRdY18Xacie2vKknvXk5CskVBbZ8'
    )
  }

  describe 'happy path' do
    it 'works', ip_address: swiss_ip_address do
      fill_in_email

      # it 'creates a new user'
      expect(last_user.email).to eq(email)
      # it 'shows a message'
      expect(page).to have_css('.thank-you')
      # it 'sends a confirmation email'
      expect(last_email.to[0]).to eq(new_email)
      expect(email_body(last_email)).to include(
        'Click here to confirm your email address'
      )

      # it 'creates a user'
      expect(last_user.email).to eq(email)

      confirm_email

      fill_in_password

      # it 'sends an SMS with a confirmation code'
      expect(Messaging::SMS::TwilioGateway::Message).
        to(receive(:to)).and_call_original

      fill_in_phone_number

      # it 'shows the number entered in the previous step'
      within('.setup') do
        expect(page).to have_text phone_number
      end

      # it 'sets phone and advances the user to the confirm phone step' do
      expect(last_sms[:to]).to eq("+#{phone_country_code}#{phone_number}")
      phone_confirmation_code = last_sms[:body].match(/\d{4}/).to_s
      confirm_phone_with_code(phone_confirmation_code)

      # it 'confirms the phone number and advances the user to the next step'
      expect(last_user.phone_confirmed?).to be(true)

      fill_in_name_and_address
      # it 'advances the user to the deposit step'
      expect_to_be_at_step(5)

      # it 'generates a deposit address'
      expect(last_user.account.addresses.deposit.count).to eq(1)

      # it 'sets the correct country code'
      expect(last_user.postal_address.country_alpha2_code).to eq('GB')

      # it 'sends the `account_set_up` email' do
      expect(last_email.subject).to match(/account is ready to fund/)

      expected_tracks = [
        'Converted To User',
        'Signed Up',
        'Confirmed Email',
        'Set Initial Password',
        'Requested Phone Confirmation Code',
        'Confirmed Phone',
        'Entered Postal Address',
        'Account Set Up'
      ]
    end

    context 'given an existing user signing up again' do
      context 'with an active session' do
        context 'without a full account' do
          it 'works', ip_address: swiss_ip_address do
            fill_in_email
            confirm_email

            fill_in_email

            # it 'does not send another welcome email'
            expect(emails_to(email).size).to eq(1)

            # it 'redirects the user to the correct signup step'
            expect(current_path).to eq(new_account_path)
            expect(page).to have_text('Get started')
          end
        end

        context 'with a full account' do
          it 'works', ip_address: swiss_ip_address do
            fill_in_email
            confirm_email
            fill_in_password
            fill_in_phone_number
            confirm_phone_with_code(last_sms[:body].match(/\d{4}/).to_s)
            fill_in_name_and_address

            fill_in_email

            # it 'sends another welcome email'
            expect(emails_to(email).size).to eq(2)

            # it 'redirects the user to the account page'
            expect(current_path).to eq(account_dashboard_path)
          end
        end
      end

      context 'given the user is logged out' do
        context 'without a full account' do
          it 'works', ip_address: swiss_ip_address do
            fill_in_email
            confirm_email
            log_out

            fill_in_email

            # it 'sends another welcome email'
            expect(emails_to(email).size).to eq(2)

            # it 'does not redirect the user anywhere'
            expect(page).to have_text('Please check your email')
          end
        end

        context 'with a full account' do
          it 'works', ip_address: swiss_ip_address do
            # it 'sends another welcome email'
            expect {
              fill_in_email
              confirm_email
              fill_in_password
              fill_in_phone_number
              confirm_phone_with_code(last_sms[:body].match(/\d{4}/).to_s)
              fill_in_name_and_address
              log_out

              fill_in_email
            }.to change { emails_to(email).size }.by(3)

            # it 'does not redirect the user anywhere'
            expect(page).to have_text('Please check your email')
          end
        end
      end
    end
  end

  describe 'unhappy paths', ignore_js_error: /422/ do
    let(:valid_phone_confirmation_code) {
      User.find_by!(email: email).phone_confirmation_code
    }
    let(:phone_confirmation_code) { valid_phone_confirmation_code }

    describe 'during email address checks' do
      before {
        fill_in_email
      }

      context 'given an already signed up user' do
        let(:email) { signed_up_user.email }

        it 'does not double up on once-off work' do
          fill_in_email

          # it 'does not create a new user'
          expect(User.count).to be(users.size)

          # it 'sends another welcome email'
          expect(emails_to(email).size).to eq(2)

          # it 'does not redirect the user to the login page'
          expect(page).not_to have_css('.login > form')
        end
      end

      context 'given a disposable email address' do
        let(:email) { 'john@mailinator.com' }

        it 'works' do
          # it 'does not allow the user to sign up'
          expect(User.count).to be(users.size)

          # it 'shows a message explaining that disposable emails are not
          # accepted'
          expect_to_see_error('must not be a disposable email')
        end
      end
    end

    describe 'during ip address checks' do
      before {
        fill_in_email
      }
      context 'given an IP address from a blacklisted country',
        ip_address: american_ip_address do

        it 'works' do
          # it 'does not create a user' do
          expect(User.count).to be(users.size)

          # it 'displays an error about blacklisted countries'
          expect_to_see_error('a country we are not allowed to serve')
        end
      end
    end

    describe 'during phone number checks' do
      before {
        complete_sign_up_steps(to_step: :fill_in_phone_number)
      }

      context 'given an invalid phone number' do
        let(:american_phone_country_code) { '1' }
        let(:american_phone_number) { '2025550102' }
        let(:phone_country_code) { american_phone_country_code }
        let(:phone_number) { american_phone_number }

        it 'sends no SMS' do
          expect(Messaging::SMS::TwilioGateway::Message).not_to receive(:to)
        end

        it 'displays an error' do
          expect_to_see_error('outside United States of America')
        end
      end
    end

    describe 'during phone number confirmation checks' do
      before {
        complete_sign_up_steps(to_step: :confirm_phone_with_code)
      }

      context 'with an invalid phone confirmation code' do
        let(:non_brittle_invalid_code) {
          valid_phone_confirmation_code == '0000' ? '0001' : '0000'
        }

        let(:phone_confirmation_code) {
          non_brittle_invalid_code
        }

        it 'works' do
          # it 'displays an error' do
          expect_to_see_error('Invalid confirmation code')

          # it 'lets users resend the code'
          within('.setup') do
            find('#resend-phone-confirmation-code').click

            expect(page).to have_text 'Confirmation code sent again'
          end

          expect(sms_messages_to("+#{phone_country_code}#{phone_number}").size).
            to eq(2)
        end
      end
    end

    describe 'during postal address checks' do
      before { complete_sign_up_steps(to_step: :fill_in_name_and_address) }

      context 'given a non-existent address' do
        let(:street_line_1) { '4000 Fake Street' }

        it 'displays validation errors' do
          expect_to_see_error('address could not be verified')
        end
      end

      context 'with a blacklisted country' do
        let(:country_alpha2_code) { 'United States of America' }

        it 'displays validation errors' do
          expect_to_see_error('cannot currently be served')
        end
      end
    end

    describe 'during sanctions list checks' do
      before { complete_sign_up_steps(to_step: :fill_in_name_and_address) }

      context 'with a name on the sanctions list' do
        let(:first_name) { 'Bashar' }
        let(:last_name) { 'al-Assad' }
        let(:email) { 'banned@example.com' }

        it 'works' do
          # it 'displays an information concealing error'
          expect_to_see_error('Error: Server down')

          # it 'bans user'
          expect(User.find_by(email: email).banned_at).not_to be_nil
        end
      end
    end
  end
end
