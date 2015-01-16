require_relative '../component'

module Mo
  module Backup
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

    end
  end
end
