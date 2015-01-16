require_relative 'component'

module Mo

  module Backup

    module OptionsDSL

    end

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


    module Syncers

      class Default < Mo::Backup::Components::Default
        alias :syncer_id :component_id
        class << self
          alias :syncer_id :component_id
        end

        attr_reader :directory

        def initialize(options)
          super
          @directory ||= self.options.delete("directory")
        end

      end

      class Rsync < Default
        option "path", :string, "backups"
        option "mode", :symbol, "rsync_daemon"
        option "host", :string
        option "port", :string, "873"
        option "mirror", :boolean, true
        option "compress", :boolean, true
        option "directory", :hash, {}
        option "rsync_user", :string
        option "rsync_password", :string
        option "ssh_user", :string
        option "additional_ssh_options", :string
        option "additional_rsync_options", :string
        syncer_id "Rsync::Push"
      end

    end

  end
end
