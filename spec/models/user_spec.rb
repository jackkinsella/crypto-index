require 'rails_helper'

RSpec.describe User do
  subject { User.new(email: 'John@Doe.com') }

  describe 'before validation' do
    it 'converts the email to lowercase' do
      expect(subject.tap(&:valid?).email).to eq('john@doe.com')
    end
  end

  describe 'validations' do
    context 'phone' do
      let(:american_phone) { '+12025550102' }
      let(:german_phone) { '+4915724548918' }

      it 'allows numbers from whitelisted countries' do
        subject.phone = german_phone
        expect(subject).to be_valid
      end

      it 'does not allow numbers from blacklisted countries' do
        subject.phone = american_phone
        expect(subject).not_to be_valid
      end
    end
  end

  describe '.sanitized_attributes' do
    context 'when `Current` is admin' do
      before {
        Current.context = :admin
      }

      it 'removes password_digest' do
        expect(subject.sanitized_attributes).not_to have_key('password_digest')
      end

      it 'keeps email' do
        expect(subject.sanitized_attributes).to have_key('email')
      end
    end

    context 'when `Current` is not admin' do
      it 'removes password_digest' do
        expect(subject.sanitized_attributes).not_to have_key('password_digest')
      end
    end
  end
end
