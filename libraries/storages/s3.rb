require_relative 'default'

module Mo
  module Backup
    module Storages
      class S3 < Default
        option "access_key_id", :string
        option "secret_access_key", :string
        option "region", :string
        option "bucket", :string
        option "path", :string
        option "keep", :number, 5
      end
    end
  end
end
