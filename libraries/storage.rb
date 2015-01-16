require_relative 'component'

module Mo
  module Backup

    class Storage < Component

      def self.prepare_information_for(storage, databag)
        main_storage = encrypted_data_bag_item(databag, storage["id"]).to_hash
        # Application defined values must overwrite default main storage values
        Chef::Mixin::DeepMerge.deep_merge!(storage, main_storage)
        main_storage
      end

      def self.lookup_module
        Mo::Backup::Storages
      end

    end


  end
end
