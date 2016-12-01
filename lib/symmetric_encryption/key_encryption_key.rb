require 'openssl/pkey'
module SymmetricEncryption
  # Class that manages the key that is used to encrypt the encryption key.
  # Currently uses RSA asymmetric encryption to secure the key.
  #
  # Note:
  #   No encoding or decoding is performed.
  class KeyEncryptionKey
    # Returns [String] a new key encryption key.
    def self.generate(options = {})
      options = options.dup
      size    = options.delete(:size) || 2048
      OpenSSL::PKey::RSA.generate(size).to_s
    end

    def initialize(key_encryption_key)
      @rsa = OpenSSL::PKey::RSA.new(key_encryption_key)
    end

    def encrypt(key)
      rsa.public_encrypt(key)
    end

    def decrypt(encrypted_key)
      rsa.private_decrypt(encrypted_key)
    end

    private

    attr_reader :rsa
  end
end
