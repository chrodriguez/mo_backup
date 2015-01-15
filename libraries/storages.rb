require_relative 'component'

module Mo
  module Backup

    class Storage < Component

      def self.prepare_information_for(storage, databag)
        main_storage = encrypted_data_bag_item(databag, storage["id"])
        # Application defined values must overwrite default main storage values
        Chef::Mixin::DeepMerge.deep_merge!(storage, main_storage)
        main_storage
      end

      def self.lookup_module
        Mo::Backup::Storages
      end

    end

    module Storages

      class Default < Components::Default

        alias :storage_id :component_id

        # Alias for class method
        class << self
          alias :storage_id :component_id
        end

      end


      class S3 < Default
        option "access_key_id", :string
        option "secret_access_key", :string
        option "region", :string
        option "bucket", :string
        option "path", :string
        option "keep", :number, 5
      end

      class Dropbox < Default
        option "api_key", :string
        option "api_secret", :string
        option "cache_path", :string, ".cache"
        option "access_type", :symbol, :app_folder
        option "path", :string, "/backups"
        option "keep", :number, 5
        option "chunk_size", :number
        option "max_retries", :number
        option "retry_waitsec", :number
      end

      class Sftp < Default
        option "username", :string, 'user'
        option "password", :string, 'pass'
        option "ip", :string
        option "port", :number, 22
        option "path", :string, "~"
        option "keep", :number, 5
        storage_id "SFTP"
      end

    end

  end
end
