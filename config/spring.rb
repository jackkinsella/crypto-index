if defined?(Spring)
  %w[
    .ruby-version
    .rbenv-vars
    tmp/restart.txt
    tmp/caching-dev.txt
    tmp/logging-dev.txt
  ].each { |path| Spring.watch(path) }
end
