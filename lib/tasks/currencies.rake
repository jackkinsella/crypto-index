namespace :currencies do
  namespace :coin_market_cap do
    desc 'Gather basic information for all currencies'
    task describe: :environment do
      url = 'https://s2.coinmarketcap.com/generated/search/quick_search.json'
      list = JSON.parse(open(url).read)

      Currency.order(:symbol).each do |currency|
        info = list.find { |item| item['symbol'] == currency.symbol }
        doc = Nokogiri::HTML(
          open(
            "https://coinmarketcap.com/currencies/#{info['slug']}/" \
            "historical-data/?start=20100101&end=#{Time.now.strftime('%Y%m%d')}"
          )
        )

        trackable_at = Date.parse(
          doc.search('#historical-data tr').
            reject { |node|
              node.text.strip.end_with?('-') ||
              (1..3).map { |n|
                (n + 1).times.inject(node) { |sibling, _|
                  sibling.send(:previous_element)
                }.text.strip.end_with?('-') rescue false
              }.all?
            }.last.css('td:first-of-type').text
        ).strftime('%Y-%m-%d')

        status =
          currency.trackable_at == Time.parse(trackable_at) ? 'green' : 'red'

        puts(
          '  ' + Rainbow("#{currency.symbol}:").rjust(6).bold.black +
          '  ' + Rainbow("slug: #{info['slug']}").ljust(30).black +
          '  ' + Rainbow("title: #{info['name']}").ljust(25).black +
          '  ' + Rainbow("trackable_at: #{trackable_at}").send(status)
        )
      rescue NoMethodError
        puts(
          '  ' + Rainbow("#{currency.symbol}:").rjust(6).bold.black +
          '  ' + Rainbow('?').red
        )
      end
    end
  end
end
