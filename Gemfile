source 'https://rubygems.org'

ruby '2.5.0'

gem 'axlsx', '~> 3.0.0.pre'
gem 'bcrypt', '~> 3.1'
gem 'bitcoin-ruby', '~> 0.0', require: 'bitcoin'
gem 'bootsnap', '~> 1.1', require: false
gem 'countries', '~> 2.1', require: 'countries/global'
gem 'descriptive_statistics', '~> 2.5', require: 'descriptive_statistics/safe'
gem 'eth', '~> 0.4'
gem 'ethereum.rb', '~> 2.2'
gem 'geoip', '~> 1.6'
gem 'ip_anonymizer', '~> 0.1'
gem 'jbuilder', '~> 2.7'
gem 'mechanize', '~> 2.7'
gem 'money-tree', '~> 0.8'
gem 'pg', '~> 0.21'
gem 'phonelib', '~> 0.6'
gem 'premailer-rails', '~> 1.10'
gem 'pry-rails', '~> 0.3'
gem 'puma', '~> 3.11'
gem 'rack-attack', '~> 5.2'
gem 'rails', '~> 5.2'
gem 'rainbow', '~> 3.0'
gem 'react-rails', '~> 2.4'
gem 'redcarpet', '~> 3.4'
gem 'retriable', '~> 3.1'
gem 'ruby-mailchecker', '~> 3.2'
gem 'scenic', '~> 1.4'
gem 'sidekiq', '~> 5.0'
gem 'sidekiq-limit_fetch', '~> 3.4'
gem 'webpacker', '~> 3.5'

group :production do
  gem 'binance-ruby', '~> 0.2'
  gem 'htmlcompressor', '~> 0.4'
  gem 'redis-rails', '~> 5.0'
  gem 'twilio-ruby', '~> 5.10'
  gem 'uglifier', '~> 4.1'
end

group :development, :test do
  gem 'byebug', '~> 9.1'
  gem 'capybara', '~> 3.2'
  gem 'chromedriver-helper', '~> 1.1'
  gem 'database_cleaner', '~> 1.7'
  gem 'factory_bot_rails', '~> 4.10'
  gem 'fixture_builder', '~> 0.5'
  gem 'redis-namespace', '~> 1.6'
  gem 'rspec-rails', '~> 3.7'
  gem 'rspec-retry', '~> 0.6'
  gem 'selenium-webdriver', '~> 3.8'
  gem 'simplecov', '~> 0.16', require: false
  gem 'timecop', '~> 0.9'
  gem 'webmock', '~> 3.3'
end

group :development do
  gem 'brakeman', '>= 4.1', require: false
  gem 'derailed_benchmarks', '~> 1.3'
  gem 'letter_opener_web', # TODO: Check for version >= v1.7
    git: 'https://github.com/fgrehm/letter_opener_web.git', branch: 'master'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'rubocop', '~> 0.58.2', require: false
  gem 'spring', '~> 2.0'
  gem 'spring-watcher-listen', '~> 2.0'
  gem 'stackprof', '~> 0.2'
  gem 'web-console', '>= 3.3'
end
