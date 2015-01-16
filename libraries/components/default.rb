require_relative '../options_dsl'

module Mo
  module Backup
    module Components

      class Default
        include Mo::Backup::OptionsDSL
      end

    end
  end
end
