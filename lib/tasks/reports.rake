namespace :reports do
  namespace :currencies do
    desc 'List top N currencies by market capitalization'
    task :maximum_market_cap, [:number] => :environment do |_, args|
      number = args[:number].blank? ? 30 : args[:number].to_i

      Reports::Currencies::MaximumMarketCap.execute!(
        date: Date.today, number: number
      ).map do |row|
        output =
          if row[:tradeable_on_supported_exchanges?]
            Rainbow(JSON.pretty_generate(row))
          else
            Rainbow(JSON.pretty_generate(row)).bold.background(:gray)
          end

        if row[:already_seen?] && !row[:rejected?]
          puts output.green
        elsif !row[:already_seen?]
          puts output.red
        else
          puts output.gray
        end
      end
    end
  end
end
