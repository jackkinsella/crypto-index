namespace :portfolios do
  namespace :rebalancings do
    desc 'Request rebalancings for all user portfolios'
    task request: :environment do
      # Portfolios::Rebalancings::RequestJob.perform_later
    end

    desc 'Realize all requested rebalancings'
    task realize: :environment do
      # Portfolios::Rebalancings::RealizeJob.perform_later
    end

    desc 'Finalize all realized rebalancings'
    task finalize: :environment do
      # Portfolios::Rebalancings::FinalizeJob.perform_later
    end
  end
end
