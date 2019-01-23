module EnumeratorInstanceExtension
  def with_progress_dots(interval: 100)
    with_index do |item, i|
      print '.' if (i % interval).zero?
      yield item
    end
    print "\n"
  end
end
safe_monkey_patch_instance(Enumerator, EnumeratorInstanceExtension)
