require 'rails_helper'

RSpec.describe 'Mailer' do
  subject { UserMailer }
  let(:user) { double(email: 'crypto_index@example.com').as_null_object }

  it 'sends plain-text and html versions of an arbitrarily chosen email' do
    email = subject.signed_up(user).deliver
    expect(email.text_part).not_to be_nil
    expect(email.html_part).not_to be_nil
  end
end
