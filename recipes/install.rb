include_recipe "chef-sugar"

Mo::Backup::Component.load_chef_sugar


include_recipe "rbenv::default"
include_recipe "rbenv::ruby_build"

ruby_version = node[:mo_backup][:ruby_version]

rbenv_ruby ruby_version do
  global true
end

rbenv_gem "backup" do
  ruby_version ruby_version
end
