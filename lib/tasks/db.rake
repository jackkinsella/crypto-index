namespace :db do
  desc 'Reset the database and flush the Redis namespace'
  task reset: :environment do
    `redis-cli --scan --pattern 'crypto_index_home:*' | xargs redis-cli unlink`
    `rm -rf tmp/blockchain/ganache`
  end

  desc 'Validate all records in the database'
  task validate: :environment do
    Rails.application.eager_load!

    ApplicationRecord.subclasses.sort_by(&:to_s).each do |model_class|
      count = model_class.count
      puts "\nValidating #{count} #{Rainbow(model_class).bold} records...\n"

      model_class.find_each.with_progress_dots do |record|
        unless record.valid?
          record.errors.full_messages.each do |error_message|
            puts(
              '  ' + Rainbow("#{model_class}(#{record.id}):").bold.red +
              '  ' + Rainbow(error_message).bold.black
            )
          end
        end
      end
    end
  end

  namespace :fixtures do
    desc 'Regenerate fixture files with FixtureBuilder'
    task regenerate: :environment do
      raise ActiveRecord::EnvironmentMismatchError unless Rails.env.test?
      load(Rails.root.join('spec/support/fixture_builder.rb'))
    end
  end

  namespace :views do
    desc 'Refresh all materialized views'
    task refresh: :environment do
      Valuation::Indicator.refresh
    end
  end
end
