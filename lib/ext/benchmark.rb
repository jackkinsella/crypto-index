module BenchmarkModuleExtension
  def log(title, message)
    data = nil
    time = Benchmark.realtime { data = yield }

    Rails.logger.debug(
      '  ' + Rainbow("#{title} (%.2fs)" % time).bold.red +
      '  ' + Rainbow(message).bold.black
    )

    data
  end
end
safe_monkey_patch_module(Benchmark, BenchmarkModuleExtension)
