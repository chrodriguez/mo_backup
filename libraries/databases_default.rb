module Mo
  module Backup
    module Databases

      class Default < Mo::Backup::Components::Default

        alias :database_id :component_id

        # Alias for class method
        class << self
          alias :database_id :component_id
        end

      end

    end
  end
end
