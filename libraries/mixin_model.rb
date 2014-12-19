$:.unshift *Dir[File.expand_path('../../files/default/vendor/gems/**/lib', __FILE__)]

require 'chef/sugar'

def mo_backup_generate_model(app, environment)

  data = encrypted_data_bag_item(app["databag"], app["id"])[environment]
  storages = get_storages(app["storages_databag"], data["backup"]["storages"])
  databases = get_databases(data["databases"])
  mail_config = get_mail_config(app["mail_databag"], data["backup"]["mail"])

  template ::File.join(::Dir.home(app["user"]),".backup_#{app["id"]}_#{environment}") do
    source "model.rb.erb"
    cookbook "mo_backup"
    variables( :app => data, :name => app["id"], :description => app["description"],
               :storages => storages, :databases => databases, :mail_config => mail_config )
  end
end

private

def get_storages(storage_databag, storages_to_use)
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
          "path"                => s["path"] || node["mo_backup"]["storage"]["path"],
          "keep"                => s["keep"] || node["mo_backup"]["storage"]["keep"]
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
