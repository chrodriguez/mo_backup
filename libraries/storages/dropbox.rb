require_relative 'default'

module Mo
  module Backup
    module Storages

      class Dropbox < Default
        option "api_key", :string
        option "api_secret", :string
        option "cache_path", :string, ".cache"
        option "access_type", :symbol, :app_folder
        option "path", :string, "/backups"
        option "keep", :number, 5
        option "chunk_size", :number
        option "max_retries", :number
        option "retry_waitsec", :number
      end

    end
  end
end
