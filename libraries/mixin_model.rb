# Chef sugar library
$:.unshift *Dir[File.expand_path('../../files/default/vendor/gems/**/lib', __FILE__)]

require 'chef/sugar'
require 'etc'

def mo_backup_generate_model(app)

  data = data_bag_item_for_environment(app["databag"], app["id"])
  Chef::Mixin::DeepMerge.deep_merge!(app, data)

  # If any of the data bags does not exist the following lines would fail. 
  # Check how to ask if a data bag is defined.
  storages = get_storages(data["id"], data["backup"]["storages_databag"], data["backup"]["storages"])
  databases = get_databases(data["databases"])
  mail_config = get_mail_config(data["backup"]["mail_databag"], data["backup"]["mail"])
  sync_config = get_sync_config(data["backup"]["syncers_databag"], data["backup"]["syncers"])

  rsync = sync_config.select {|r| r["rsync"]}
  if !rsync.empty?
    write_pub_key(app["user"], rsync)
  end

  template ::File.join(::Dir.home(data["user"]), data["backup"]["models_dir"] || "Backup/models", "#{data["id"]}_#{node.chef_environment}.rb") do
    owner data["user"]
    group get_group(data["user"])
    source "model.rb.erb"
    cookbook "mo_backup"
    variables( :app => data, :name => "#{data["id"]}_#{node.chef_environment}", :description => data["description"],
               :storages => storages, :databases => databases, :sync_config => sync_config,
               :mail_config => mail_config )
  end
end

def mo_backup_schedule_job(app, action="create")

  data = data_bag_item_for_environment(app["databag"], app["id"])["backup"]

  cron app["id"] do
    minute data["schedule"]["minute"]    || "0"
    hour data["schedule"]["hour"]        || "2"
    day data["schedule"]["day"]          || "*"
    month data["schedule"]["month"]      || "*"
    weekday data["schedule"]["weekday"]  || "*"
    user app["user"]                     || "root"
    command "/opt/rbenv/shims/backup perform --trigger #{app["id"]}_#{node.chef_environment}"
    action action.to_sym
  end
end

private

def get_storages(application_id, storage_databag, storages_to_use)
  storages_to_use.map do |s; enc_storage|
    enc_storage = encrypted_data_bag_item(storage_databag, s["id"])
    {
      enc_storage["type"] => [
        {
          "access_key_id"       => enc_storage["access_key_id"],
          "secret_access_key"   => enc_storage["secret_access_key"],
          "region"              => enc_storage["region"],
          "bucket"              => enc_storage["bucket"],
          "encryption"          => enc_storage["encryption"],
          "username"            => enc_storage["username"],
          "password"            => enc_storage["password"],
          "host"                => enc_storage["host"],
          "path"                => ::File.join(s["path"] || application_id, node.chef_environment),
          "keep"                => s["keep"] || 5
        }
      ]
    }
  end
end

def get_databases(databases)
  databases.map do |db|
    {
      db["type"] => [
        {
          "name"       => db["name"],
          "username"   => db["username"],
          "password"   => db["password"],
          "host"       => db["host"],
          "port"       => db["port"]
        }
      ]
    }
  end
end

def get_sync_config(syncers_databag, syncers_to_use)
  syncers_to_use.map do |s; enc_syncer|
    enc_syncer = encrypted_data_bag_item(syncers_databag, s["id"])
    {
      enc_syncer["type"] => [
        {
          "mode"                      => enc_syncer["mode"],
          "host"                      => enc_syncer["host"],
          "port"                      => enc_syncer["port"],
          "ssh_user"                  => enc_syncer["ssh_user"],
          "ssh_pubkey"                => enc_syncer["ssh_pubkey"],
          "ssh_pubkey_file"           => enc_syncer["ssh_pubkey_file"],
          "additional_ssh_options"    => enc_syncer["additional_ssh_options"],
          "additional_rsync_options"  => enc_syncer["additional_rsync_options"],
          "ssh_pubkey_file"           => enc_syncer["ssh_pubkey_file"],
          "mirror"                    => enc_syncer["mirror"],
          "compress"                  => enc_syncer["compress"],
          "directory"                 => s["directory"],
          "path"                      => enc_syncer["path"],
        }
      ]
    }
  end
end

def get_mail_config(mail_databag, mail)
  enc_mail_config = encrypted_data_bag_item(mail_databag, mail["mail_id"])
  mail_config = {
    "from" => enc_mail_config["from"],
    "to" => enc_mail_config["to"],
    "address" => enc_mail_config["address"],
    "port" => enc_mail_config["port"],
    "domain" => enc_mail_config["domain"],
    "user_name" => enc_mail_config["user_name"],
    "password" => enc_mail_config["password"],
    "authentication" => enc_mail_config["authentication"],
    "encryption" => enc_mail_config["encryption"]
  }
  Chef::Mixin::DeepMerge.deep_merge(mail, mail_config)
end

# This method creates every public key file with the content specified.
def write_pub_key(user, rsync)
  rsync.first["rsync"].each do |r|
    if !r["ssh_pubkey_file"].nil?
      file File.join(::Dir.home(user), ".ssh/#{r["ssh_pubkey_file"]}") do
        owner user
        group get_group(user)
        mode '0750'
        content r["ssh_pubkey"]
        action :create
      end
    end
  end
end

def get_group(user)
  Etc.getgrgid(Etc.getpwnam(user).gid).name
end
