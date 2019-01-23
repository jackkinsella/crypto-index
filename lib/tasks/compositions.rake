namespace :compositions do
  desc 'Create compositions for all portfolios'
  task create: :environment do
    Compositions::CreateJob.perform_later
  end
  task update: :create
end
