namespace :dev do
  task :log do
    desc 'Toggle development mode debug logging on/off'

    if File.exist? 'tmp/logging-dev.txt'
      File.delete 'tmp/logging-dev.txt'
      puts 'Development mode is no longer being debug logged.'
    else
      FileUtils.touch 'tmp/logging-dev.txt'
      puts 'Development mode is now being debug logged.'
    end
  end
end
