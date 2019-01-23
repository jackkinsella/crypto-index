module Authentication
  extend ActiveSupport::Concern

  included do
    def log_in(user:, password: 'password')
      visit login_path

      fill_in :'user[email]', with: user.email
      fill_in :'user[password]', with: password

      find('[type="submit"]').click and wait
    end

    def visit_with_http_basic_auth(path)
      credentials = {
        username: Rails.application.credentials.admin.name,
        password: Rails.application.credentials.admin.password
      }

      visit home_path

      visit "#{current_url.gsub(
        /(?<=\/\/)/,
          "#{credentials[:username]}:#{credentials[:password]}@"
      )}#{path[1..-1]}"
    end
  end
end
