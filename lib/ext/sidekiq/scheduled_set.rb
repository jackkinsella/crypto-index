module Sidekiq
  module ScheduledSetInstanceExtension
    def exists?(job_class, arguments = {})
      any? { |job|
        job['args'].first['job_class'] == job_class.to_s &&
        job['args'].first['arguments'].first.
          except('_aj_symbol_keys') == arguments.stringify_keys
      }
    end
  end
end
safe_monkey_patch_instance(
  Sidekiq::ScheduledSet, Sidekiq::ScheduledSetInstanceExtension
)
