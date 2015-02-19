require 'etc'

def mo_backup_generate_model(app)

  data = data_bag_item_for_environment(app["databag"], app["id"])
  Chef::Mixin::DeepMerge.deep_merge!(app, data)

  # If any of the data bags does not exist the following lines would fail. 
  # Check how to ask if a data bag is defined.
  storages = get_storages(data["backup"]["storages_databag"] || node["mo_backup"]["storages_databag"], data["backup"]["storages"])
  databases = get_databases(data["databases"])
  mail_config = get_mail_config(data["backup"]["mail_databag"] || node["mo_backup"]["mail_databag"], data["backup"]["mail"])
  syncers = get_syncers(data["backup"]["syncers_databag"] || node["mo_backup"]["syncers_databag"], data["backup"]["syncers"])

  directory ::File.join(::Dir.home(data["user"]), data["backup"]["models_dir"] || "Backup/models") do
    owner data["user"]
    group get_group(data["user"])
    action :create
    recursive true
  end

  template ::File.join(::Dir.home(data["user"]), data["backup"]["models_dir"] || "Backup/models", "#{data["id"]}_#{node.chef_environment}.rb") do
    owner data["user"]
    group get_group(data["user"])
    source "model.rb.erb"
    cookbook "mo_backup"
    variables( :app => data, :name => "#{data["id"]}_#{node.chef_environment}", :description => data["description"],
               :storages => storages, :databases => databases, :syncers => syncers,
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

def get_group(user)
  Etc.getgrgid(Etc.getpwnam(user).gid).name
end
