module Mo
  module Backup

    class Syncer < Component

      def self.prepare_information_for(syncer, databag)
        main_syncer = encrypted_data_bag_item(databag, syncer["id"]).to_hash
        Chef::Mixin::DeepMerge.deep_merge!(syncer, main_syncer)
        main_syncer
      end

      def self.lookup_module
        Mo::Backup::Syncers
      end

    end


  end
end
