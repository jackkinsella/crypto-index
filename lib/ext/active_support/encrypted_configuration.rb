module CredentialsExtension
  def config
    return super.to_open_struct if Rails.env.production?

    file = 'config/credentials.yml'
    enable_alias = true

    YAML.safe_load(
      File.read(Rails.root.join(file)), [], [], enable_alias
    )[Rails.env].to_open_struct
  end
end
ActiveSupport::EncryptedConfiguration.prepend(CredentialsExtension)
