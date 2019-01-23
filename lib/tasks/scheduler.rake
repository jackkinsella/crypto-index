namespace :scheduler do
  namespace :every_10_minutes do
    task all: [
      :'accounts:deposits:track',
      :'accounts:deposits:finalize',
      :'allocations:update',
      :'db:views:refresh',
      :'compositions:update',
      :'portfolios:rebalancings:finalize',
      :'portfolios:rebalancings:realize',
      :'portfolios:rebalancings:request',
      :'valuations:update'
    ]
  end

  namespace :hourly do
    task all: [
      :'allocations:create',
      :'valuations:create'
    ]
  end

  namespace :daily do
    task all: []
  end
end
