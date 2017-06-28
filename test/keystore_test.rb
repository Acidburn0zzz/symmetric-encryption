require_relative 'test_helper'

module SymmetricEncryption
  class KeystoreTest < Minitest::Test
    describe SymmetricEncryption::Keystore do
      let :key_encryption_key do
        rsa_key = SymmetricEncryption::KeyEncryptionKey.generate
        SymmetricEncryption::KeyEncryptionKey.new(rsa_key)
      end

      let :keystore do
        SymmetricEncryption::Keystore::File.new(file_name: 'tmp/tester.key', key_encryption_key: key_encryption_key)
      end

      after do
        # Cleanup generated encryption key files.
        `rm tmp/tester* 2>/dev/null`
      end

      describe '.rotate_keys' do
        let :environments do
          %i(development test acceptance preprod production)
        end

        let :config do
          SymmetricEncryption::Keystore::File.new_config(
            key_path:     'tmp',
            app_name:     'tester',
            environments: environments,
            cipher_name:  'aes-128-cbc'
          )
        end

        let :rolling_deploy do
          false
        end

        let :key_rotation do
          SymmetricEncryption::Keystore.rotate_keys!(
            config,
            environments:   environments,
            app_name:       'tester',
            rolling_deploy: rolling_deploy
          )
        end

        it 'creates an encrypted key file for all non-test environments' do
          (environments - %i(development test)).each do |env|
            assert ciphers = key_rotation[env.to_sym][:ciphers], "Environment #{env} is missing ciphers: #{key_rotation[env.to_sym].inspect}"
            assert_equal 2, ciphers.size, "Environment #{env}: #{ciphers.inspect}"
            assert new_cipher = ciphers.first
            assert file_name = new_cipher[:key_filename], "Environment #{env} is missing key_filename: #{ciphers.inspect}"
            assert File.exist?(file_name)
            assert_equal 2, new_cipher[:version]
          end
        end
      end

    end
  end
end
