#
# Format:
#
#   throttle('<ROUTE NAME>:<THROTTLE PARAMETER>', <THROTTLE OPTIONS>) do
#     ...
#   end
#
# The list is sorted alphabetically by <ROUTE NAME>.
#
class Rack::Attack
  THROTTLE_1_000_PER_1M = {limit: 1_000, period: 1.minute}.freeze
  THROTTLE_5_PER_10M = {limit: 5, period: 10.minutes}.freeze
  THROTTLE_10_PER_1H = {limit: 10, period: 1.hour}.freeze
  THROTTLE_50_PER_1H = {limit: 50, period: 1.hour}.freeze

  throttle('*:ip', THROTTLE_1_000_PER_1M, &:ip)

  throttle('confirm_withdrawal_by_email:ip', THROTTLE_10_PER_1H) do |request|
    request.ip if request.path.match?(/\/withdrawals\/[^\/]+\/confirm\//)
  end

  throttle('login:email', THROTTLE_5_PER_10M) do |request|
    if request.post? && request.path == '/login'
      request.params['email'].presence
    end
  end

  throttle('signup:ip', THROTTLE_50_PER_1H) do |request|
    request.ip if request.post? && request.path == '/signup'
  end
end
