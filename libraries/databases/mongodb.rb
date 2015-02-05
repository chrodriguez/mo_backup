require_relative 'default'

module Mo
  module Backup
    module Databases
      class Mongodb < Default
        option "name", :string
        option "username", :string
        option "password", :string
        option "host", :string, "localhost"
        option "port", :number, 27017
        option "ipv6", :boolean, false
        option "lock", :boolean, false
        option "oplog", :boolean, false
        option "only_collections", :array
        option "additional_options", :array
        database_id "MongoDB"
      end
    end
  end
end
