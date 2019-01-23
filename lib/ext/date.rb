module DateClassExtension
  def partition(start_date, end_date, resolution: 1.month)
    dates = [start_date]
    dates << dates.last + resolution while dates.last + resolution <= end_date
    dates
  end
end
safe_monkey_patch_class(Date, DateClassExtension)
