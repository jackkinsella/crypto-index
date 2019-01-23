module JSONClassExtension
  def read_config_data(name, environment = nil)
    extension = ".#{environment}" if environment.present?
    JSON.parse(
      File.read("#{Rails.root}/config/data/#{name}#{extension}.json")
    )
  end
end
safe_monkey_patch_class(JSON, JSONClassExtension)
