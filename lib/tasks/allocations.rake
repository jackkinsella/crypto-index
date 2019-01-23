namespace :allocations do
  desc 'Create initial allocations for all indexes'
  task bootstrap: :environment do
    Valuations::CreateJob.perform_later(
      from_date: (CryptoIndex::GENESIS_DATE - 1.day).to_s,
      to_date: CryptoIndex::GENESIS_DATE.to_s
    )

    unless Index.allocations_at?(CryptoIndex::GENESIS_DATE)
      Allocations::CreateJob.set(wait: 5.minutes).perform_later(
        from_date: CryptoIndex::GENESIS_DATE.to_s
      )
    end
  end

  desc 'Create allocations for all indexes'
  task :create, [:from_date, :to_date] => :environment do |_, args|
    if args[:from_date].blank? && args[:to_date].blank?
      from_date = Date.yesterday
      to_date = Date.today
    else
      from_date = Date.parse(args[:from_date])
      to_date = Date.parse(args[:to_date]) rescue from_date
    end

    Allocations::CreateJob.perform_later(
      from_date: from_date&.to_s,
      to_date: to_date&.to_s
    )
  end
  task update: :create
end
