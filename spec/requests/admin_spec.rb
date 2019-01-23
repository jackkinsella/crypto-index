require 'rails_helper'

RSpec.describe '/admin' do
  it 'redirects to `/users`' do
    get '/admin'

    expect(response).to redirect_to('/admin/users')
  end

  describe '/admin/*' do
    it 'is protected by HTTP Basic authentication' do
      get '/admin/users'

      expect(response).not_to be_successful
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe '/admin/jobs' do
    it 'is protected by HTTP Basic authentication' do
      get '/admin/jobs'

      expect(response).not_to be_successful
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
