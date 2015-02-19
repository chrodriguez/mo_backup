module Mo
  module Backup
    module Storages
      class Scp < Default
        option "username", :string, 'user'
        option "password", :string, 'pass'
        option "ip", :string
        option "port", :number, 22
        option "path", :string, "~"
        option "keep", :number, 5
        storage_id "SCP"
      end
    end
  end
end
