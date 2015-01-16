require_relative 'default'

module Mo
  module Backup
    module Syncers

      class Rsync < Default
        option "path", :string, "backups"
        option "mode", :symbol, "rsync_daemon"
        option "host", :string
        option "port", :string, "873"
        option "mirror", :boolean, true
        option "compress", :boolean, true
        option "directory", :hash, {}
        option "rsync_user", :string
        option "rsync_password", :string
        option "ssh_user", :string
        option "additional_ssh_options", :string
        option "additional_rsync_options", :string
        syncer_id "Rsync::Push"
      end

    end
  end
end
