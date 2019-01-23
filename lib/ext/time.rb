module TimeInstanceExtension
  def round_up(resolution: 1.hour)
    Time.at((to_f / resolution).ceil * resolution)
  end

  def round_down(resolution: 1.hour)
    Time.at((to_f / resolution).floor * resolution)
  end
end
safe_monkey_patch_instance(Time, TimeInstanceExtension)

module TimeClassExtension
  def partition(start_time, end_time, resolution: 1.hour)
    (start_time.to_time.to_i..end_time.to_time.to_i).
      step(resolution).map { |time| Time.at(time) }
  end

  def partition_over(start_time, time_span, resolution: 1.hour)
    partition(start_time - (time_span - resolution), start_time)
  end
end
safe_monkey_patch_class(Time, TimeClassExtension)
