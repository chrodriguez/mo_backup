module Mo
  module Backup
    module Storages

      class Default < Mo::Backup::Components::Default

        alias :storage_id :component_id

        # Alias for class method
        class << self
          alias :storage_id :component_id
        end

      end

    end
  end
end

require_relative 'dropbox'
require_relative 's3'
require_relative 'scp'
require_relative 'sftp'

