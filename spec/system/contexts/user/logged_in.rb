RSpec.shared_context 'User: Logged in' do
  let(:user) { users(:signed_up) }

  before { log_in(user: user) }
end
