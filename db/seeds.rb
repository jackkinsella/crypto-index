puts "\n== Seeding currencies =="
CSV.read_config_data(:currencies).each do |data|
  puts data['title']

  Currency.find_or_initialize_by(symbol: data['symbol']).update!(
    data.to_hash
  )

  if Rails.env.development?
    sources = [
      'cjdowner/cryptocurrency-icons/master/svg/color/%{downcased}.svg',
      'AllienWorks/cryptocoins/master/SVG/%{upcased}.svg'
    ]
    local_directory = "#{Rails.root}/app/assets/images/icons/currencies"
    local_icon_path = "#{local_directory}/#{data['symbol'].downcase}.svg"

    sources.each.with_index do |source, index|
      unless File.exists?(local_icon_path)
        begin
          remote_icon_path = "https://raw.githubusercontent.com/#{source}" % {
            upcased: data['symbol'], downcased: data['symbol'].downcase
          }
          File.write(local_icon_path, open(remote_icon_path).read)
        rescue OpenURI::HTTPError
          if index == sources.size - 1
            puts "Warning: Can't find the icon for #{data['symbol']}!"
          end
        end
      end
    end
  end
end

puts "\n== Seeding indexes =="
CSV.read_config_data(:indexes).each do |data|
  puts data['title']

  Index.find_or_initialize_by(symbol: data['symbol']).update!(
    data.to_hash
  )
end

puts "\n== Seeding markets =="
CSV.read_config_data(:markets).each do |data|
  puts data['title']

  Market.find_or_initialize_by(name: data['name']).update!(
    data.to_hash
  )
end

if Rails.env.development?
  puts "\n== Seeding users (development) =="
  CSV.read_config_data(:users, :development).each do |data|
    puts data['email']

    user = User.find_or_initialize_by(email: data['email'])
    user.update!(
      data.to_hash.slice(*%w[email password phone first_name last_name]).merge(
        email_confirmed_at: Time.now,
        phone_confirmed_at: Time.now
      )
    )
    unless user.postal_address?
      user.create_postal_address!(
        data.to_hash.slice(*%w[
          street_line_1 street_line_2 zip_code city region country_alpha2_code
        ])
      )
    end
    unless user.addresses.deposit.exists?
      user.addresses.deposit.generate_for!(
        owner: user.account,
        currency: Currency.eth,
        category: :deposit
      )
    end
  end

  valuations = Valuation.between(
    Date.parse('2016-12-31'), Date.parse('2017-01-10').end_of_day
  )
  unless valuations.count == 9_768
    puts "\n== Seeding valuations (development) =="
    JSON.read_config_data(:valuations, :development).each do |data|
      print '.'

      currency = Currency.find_by(symbol: data.dig('currency', 'symbol'))
      unless Valuation.exists?(currency: currency, timestamp: data['timestamp'])
        ApplicationRecord.connection.execute(
          <<~SQL
            INSERT INTO valuations (
              currency_id,
              timestamp,
              market_cap_usd,
              price_usd,
              circulating_supply,
              stale,
              created_at,
              updated_at
            ) VALUES (
              #{currency.id},
              '#{data['timestamp']}',
              '#{data['market_cap_usd']}',
              '#{data['price_usd']}',
              '#{data['circulating_supply']}',
              TRUE,
              '#{Time.now}',
              '#{Time.now}'
            )
          SQL
        )
      end
    end
    print "\n"
  end

  allocations = Index::Allocation.between(
    Date.parse('2016-12-31'), Date.parse('2017-01-10').end_of_day
  )
  unless allocations.count == 240
    puts "\n== Seeding index allocations (development) =="
    JSON.read_config_data(:allocations, :development).each do |data|
      print '.'

      index = Index.find_by(name: data.dig('index', 'name'))
      Index::Allocation.create_with(
        value: data['value'],
        components: data['components'].map { |component|
          Index::Component.new(
            currency: Currency.find_by(
              symbol: component.dig('currency', 'symbol')
            ),
            weight: component['weight']
          )
        }
      ).find_or_create_by!(
        index: index,
        timestamp: data['timestamp']
      )
    end
    print "\n"
  end
end
