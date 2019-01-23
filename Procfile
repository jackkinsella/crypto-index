release: rails db:migrate && rails db:seed && rails app:verify
web: bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq -C config/sidekiq.yml
