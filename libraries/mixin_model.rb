require 'etc'

def mo_backup_generate_model(data)

  # Generate empty config.rb if it does not exist.
  file "backuo config file #{data["id"]}" do
    lazy { ::File.join(::Dir.home(data['backup']["user"]), data["backup"]["dir"] || node["mo_backup"]["dir"], "config.rb")}
    content "# Backup v4.x Configuration"
    owner data['backup']["user"]
    mode '0755'
    action :create
  end

  # If any of the data bags does not exist the following lines would fail. 
  # Check how to ask if a data bag is defined.
  storages = get_storages(data["backup"]["storages_databag"] || node["mo_backup"]["storages_databag"], data["backup"]["storages"])
  databases = get_databases(mo_backup_slice(data["databases"], data['backup']['databases']))
  mail_config = get_mail_config(data["backup"]["mail_databag"] || node["mo_backup"]["mail_databag"], data["backup"]["mail"])
  syncers = get_syncers(data["backup"]["syncers_databag"] || node["mo_backup"]["syncers_databag"], data["backup"]["syncers"])

  directory "backup model directory for #{data["id"]}" do
    path lazy {::File.join(::Dir.home(data['backup']["user"]), data["backup"]["models_dir"] || node["mo_backup"]["models_dir"])}
    owner data['backup']["user"]
    action :create
    recursive true
  end

  template "backup model template #{data["id"]}" do
    source lazy {::File.join(::Dir.home(data['backup']["user"]), data["backup"]["models_dir"] || node["mo_backup"]["models_dir"], "#{data["id"]}_#{node.chef_environment}.rb")}
    owner data['backup']["user"]
    source "model.rb.erb"
    cookbook "mo_backup"
    variables( :app => data, :name => "#{data["id"]}_#{node.chef_environment}", :description => data["description"],
               :storages => storages, :databases => databases, :syncers => syncers,
               :mail_config => mail_config )
  end
end

def mo_backup_schedule_job(data)
  cron data["id"] do
    minute data["backup"]["schedule"]["minute"]    || "0"
    hour data["backup"]["schedule"]["hour"]        || "2"
    day data["backup"]["schedule"]["day"]          || "*"
    month data["backup"]["schedule"]["month"]      || "*"
    weekday data["backup"]["schedule"]["weekday"]  || "*"
    user data['backup']["user"]                    || "root"
    command "/opt/rbenv/shims/backup perform --trigger #{data["id"]}_#{node.chef_environment}"
    action (data["backup"]['enabled'].nil? || data["backup"]['enabled']) ? :create : :delete
  end
end

private

def get_storages(storage_databag, storages_to_use)
  Mo::Backup::Storage.build(storages_to_use, storage_databag)
end

def get_databases(databases)
  Mo::Backup::Database.build(databases.values)
end

def get_syncers(syncers_databag, syncers_to_use)
  Mo::Backup::Syncer.build(syncers_to_use, syncers_databag)
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

def mo_backup_slice(hash, keys)
  keys.each_with_object(Hash.new) {|k,h| h[k] = hash[k] }
end

