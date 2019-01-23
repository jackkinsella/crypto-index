require 'rails_helper'

RSpec.describe 'Pages' do
  describe 'home' do
    it 'renders' do
      visit home_path

      # TODO: Replace with:
      # it 'shows the M10 currencies in alphabetical order'
      expect(page).to have_text('CryptoIndex')
    end
  end

  describe 'terms' do
    xit 'renders' do
      visit terms_path
    end
  end

  describe 'privacy' do
    xit 'renders' do
      visit privacy_path
    end
  end

  describe 'about' do
    let(:page) { about_path }
    xit 'renders' do
      visit about_path
    end
  end
end
