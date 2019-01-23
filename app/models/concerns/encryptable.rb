module Encryptable
  extend ActiveSupport::Concern

  ASYMMETRIC_ENCRYPTION_SETTINGS = {
    digest: OpenSSL::Digest::SHA256.new,
    key_length: 4_096
  }.freeze

  class_methods do
    def encrypted_attributes(*args)
      options = args.last.is_a?(Hash) ? args.pop : {}
      names = args

      if options[:asymmetric] == true
        _define_asymmetric_accessors(names)
      else
        _define_symmetric_accessors(names)
      end

      _define_convenience_methods(names)
    end

    def _define_asymmetric_accessors(names)
      names.each do |name|
        attr_reader :"#{name}"

        class_eval <<~RUBY, __FILE__, __LINE__ + 1
          def #{name}=(value)
            @#{name} = value
            self[:#{name}_enc] = encrypt_asymmetric(value)
          end
        RUBY
      end
    end

    def _define_symmetric_accessors(names)
      names.each do |name|
        class_eval <<~RUBY, __FILE__, __LINE__ + 1
          def #{name}
            @#{name} ||= decrypt_symmetric(#{name}_enc)
          end

          def #{name}=(value)
            @#{name} = value
            self[:#{name}_enc] = encrypt_symmetric(value)
          end
        RUBY
      end
    end

    def _define_convenience_methods(names)
      names.each do |name|
        class_eval <<~RUBY, __FILE__, __LINE__ + 1
          def #{name}?
            #{name}_enc.present?
          end
        RUBY
      end
    end
  end

  def encrypt_asymmetric(secret)
    asymmetric_encryptor.public_encrypt(secret)
  end

  def encrypt_symmetric(secret)
    symmetric_encryptor.encrypt_and_sign(secret)
  end

  def decrypt_symmetric(ciphertext)
    symmetric_encryptor.decrypt_and_verify(ciphertext) if ciphertext.present?
  end

  class EncryptionKeyNotConfiguredError < StandardError; end

  private

  def asymmetric_encryption_key
    Rails.application.credentials.secret_keys.asymmetric.public_key
  end

  def symmetric_encryption_key
    Base64.urlsafe_decode64(
      Rails.application.credentials.secret_keys.symmetric
    ).first(32)
  end

  def asymmetric_encryptor
    OpenSSL::PKey::RSA.new(asymmetric_encryption_key)
  end

  def symmetric_encryptor
    ActiveSupport::MessageEncryptor.new(symmetric_encryption_key)
  end
end
