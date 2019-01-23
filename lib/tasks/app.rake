namespace :app do
  desc 'Verify that the application does not crash on boot'
  task verify: :environment do
    Rails.application.eager_load!
  end
end
