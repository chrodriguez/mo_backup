# General attributes
default[:mo_backup][:ruby_version] = "2.1.4"

# Databag locations
default["mo_backup"]["storages_databag"] = "backup_storages"
default["mo_backup"]["syncers_databag"] = "backup_syncers"
default["mo_backup"]["mail_databag"] = "mailers"
