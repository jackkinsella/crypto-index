require_relative 'boot'

require 'rails'
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'

require 'csv'
require 'sidekiq/web'

Bundler.require(*Rails.groups)

File.expand_path('..', __dir__).tap do |app_root|
  require "#{app_root}/lib/ext/object.rb"
  Dir["#{app_root}/lib/ext/**/*.rb"].each { |file| require file }
end

module CryptoIndex
  GENESIS_DATE = Date.new(2017, 1, 1)
  LAUNCH_DATE = Date.new(2018, 7, 20)
  RELEASE_DATE = Date.new(2018, 8, 10)

  VERSION = '1.0.1'.freeze
  PLATFORM = 'Web'.freeze
  DOMAIN = 'example.com'.freeze
  TAGLINE = 'CryptoIndex Market10'.freeze

  Rainbow.enabled = true

  class Application < Rails::Application
    ENV['FIXTURES_PATH'] = 'spec/fixtures'

    config.load_defaults 5.2
    config.active_job.queue_adapter = :sidekiq

    config.time_zone = 'UTC'
    config.active_record.default_timezone = :utc
    config.active_record.time_zone_aware_attributes = false
    config.middleware.use Rack::Attack

    if Rails.env.production?
      config.middleware.use HtmlCompressor::Rack

      if Rails.server?
        config.after_initialize do
          Rails.application.load_tasks
          Rake::Task[:'valuations:bootstrap'].invoke
          Rake::Task[:'allocations:bootstrap'].invoke
        end
      end
    end
  end
end
