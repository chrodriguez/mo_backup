module Mo
  module Backup
    module Databases
      class Redis < Default
        option "mode", :symbol, "copy"
        option "host", :string, "localhost"
        option "port", :number, 6379
        option "socket", :string
        option "password", :string
        option "rdb_path", :string
        option "additional_options", :array
        option "invoke_save", :boolean, false
      end
    end
  end
end
