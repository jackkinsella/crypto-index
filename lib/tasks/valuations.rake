namespace :valuations do
  desc 'Create initial valuations for all currencies'
  task bootstrap: :environment do
    start_date =  Rails.application.config.settings.bootstrap.start_date
    dates = Date.partition(start_date, Date.today, resolution: 1.day)
    delay = 0.minutes

    dates.reverse.each do |date|
      next if Valuation.on(date).exists? ||
        Sidekiq::ScheduledSet.new.exists?(
          Valuations::CreateJob, from_date: date&.to_s
        )

      loop do
        delay += 1.minute
        break if (delay + 10.minutes).from_now.min >= 20
      end

      Valuations::CreateJob.set(wait: delay).perform_later(
        from_date: date&.to_s
      )
    end
  end

  desc 'Create or update valuations for all currencies'
  task :create, [:from_date, :to_date] => :environment do |_, args|
    if args[:from_date].blank? && args[:to_date].blank?
      from_date = Date.yesterday
      to_date = Date.today
    else
      from_date = Date.parse(args[:from_date])
      to_date = Date.parse(args[:to_date]) rescue from_date
    end

    Valuations::CreateJob.perform_later(
      from_date: from_date&.to_s,
      to_date: to_date&.to_s
    )
  end
  task update: :create

  desc 'Validate valuations for all currencies'
  task :validate, [:from_date, :to_date, :options] => :environment do |_, args|
    if args[:from_date].blank? && args[:to_date].blank?
      from_date = Date.today.beginning_of_month
      to_date = Date.today
    else
      from_date = Date.parse(args[:from_date])
      to_date = Date.parse(args[:to_date]) rescue from_date
    end

    puts "\nValidating valuations for #{Currency.count} currencies...\n"

    delay = 0.seconds

    Currency.order(:symbol).each do |currency|
      start_time = [currency.trackable_at, from_date].max
      end_time = [currency.rejected_at, Time.now, to_date + 1.day].compact.min
      missing_timestamps = Time.partition(start_time, end_time - 1.hour) -
        currency.valuations.between(start_time, end_time).pluck(:timestamp)

      next if missing_timestamps.blank? ||
        missing_timestamps.map(&:to_date).uniq == [currency.trackable_at]

      puts(
        '  ' + Rainbow("#{currency} has missing timestamps:").bold.red +
        '  ' + Rainbow(missing_timestamps.join(', ')).bold.black
      )

      next if (args[:options] || '').split('&').exclude?('repair=true')

      dates = missing_timestamps.map { |time| Time.at(time).to_date }.uniq

      dates.each do |date|
        loop do
          delay += 15.seconds
          break if (delay + 10.minutes).from_now.min >= 20
        end

        Valuations::CreateJob.set(wait: delay).perform_later(
          from_date: date.to_s, currencies: [currency.to_s]
        )

        puts(
          '  ' + Rainbow('Attempting repair:').bold.cyan +
          '  ' + Rainbow("#{currency} for #{date} in #{delay}s...").bold.green
        )
      end
    end
  end
end
