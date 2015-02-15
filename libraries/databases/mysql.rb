module Mo
  module Backup
    module Databases
      class Mysql < Default
        option "name", :string
        option "username", :string
        option "password", :string
        option "host", :string, "localhost"
        option "port", :number, 3306
        option "socket", :string
        option "sudo_user", :string, "root"
        option "skip_tables", :string
        option "only_tables", :string
        option "additional_options", :array
        option "prepare_backup", :boolean, true
        database_id "MySQL"
      end
    end
  end
end
