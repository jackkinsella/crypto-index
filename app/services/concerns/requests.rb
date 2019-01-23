require 'open-uri'

module Requests
  TIMEOUT_SECONDS = 10

  class DownError < StandardError; end
  class NotFoundError < StandardError; end
  class RateLimitError < StandardError; end

  def read_page(endpoint, cache_for: 0.seconds)
    block = proc {
      Benchmark.log('Page Load', endpoint) {
        open_carefully(endpoint)
      }
    }

    return block.call if cache_for.zero?

    cache_key = "requests#read_page/#{endpoint}"
    Rails.cache.fetch cache_key, expires_in: cache_for, &block
  end

  def read_api(endpoint, cache_for: 0.seconds)
    block = proc {
      Benchmark.log('API Load', endpoint) {
        JSON.parse(open_carefully(endpoint), symbolize_names: true)
      }
    }

    return block.call if cache_for.zero?

    cache_key = "requests#read_api/#{endpoint}"
    Rails.cache.fetch cache_key, expires_in: cache_for, &block
  end

  private

  def open_carefully(endpoint)
    opts = {read_timeout: TIMEOUT_SECONDS}
    open(endpoint, opts).read
  rescue OpenURI::HTTPError => error
    raise NotFoundError if error.message.include?('404')
    raise DownError, error.message
  rescue Net::ReadTimeout, Net::OpenTimeout
    raise DownError, <<~TEXT
      The request to #{endpoint} timed out after #{TIMEOUT_SECONDS} seconds
    TEXT
  end
end
