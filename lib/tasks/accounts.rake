namespace :accounts do
  namespace :deposits do
    desc 'Track deposits to all user accounts'
    task track: :environment do
      # (0..9).each do |delay|
      #   Accounts::Deposits::TrackJob.set(wait: delay.minutes).perform_later
      # end
    end

    desc 'Finalize all realized deposits'
    task finalize: :environment do
      # Accounts::Deposits::FinalizeJob.perform_later
    end
  end
end
