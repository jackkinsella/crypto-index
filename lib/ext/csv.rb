module CSVClassExtension
  def read_config_data(name, environment = nil)
    extension = ".#{environment}" if environment.present?
    CSV.read(
      "#{Rails.root}/config/data/#{name}#{extension}.csv", headers: true
    )
  end
end
safe_monkey_patch_class(CSV, CSVClassExtension)
