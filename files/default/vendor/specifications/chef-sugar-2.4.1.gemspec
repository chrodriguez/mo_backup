# -*- encoding: utf-8 -*-
# stub: chef-sugar 2.4.1 ruby lib

Gem::Specification.new do |s|
  s.name = "chef-sugar"
  s.version = "2.4.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Seth Vargo"]
  s.date = "2014-10-12"
  s.description = "A series of helpful sugar of the Chef core and other resources to make a cleaner, more lean recipe DSL, enforce DRY principles, and make writing Chef recipes an awesome experience!"
  s.email = ["sethvargo@gmail.com"]
  s.homepage = "https://github.com/sethvargo/chef-sugar"
  s.licenses = ["Apache 2.0"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9")
  s.rubygems_version = "2.2.1"
  s.summary = "A collection of helper methods and modules that make working with Chef recipes awesome."

  s.installed_by_version = "2.2.1" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>, ["~> 1.3"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<chefspec>, ["~> 4.0"])
      s.add_development_dependency(%q<test-kitchen>, ["~> 1.1"])
      s.add_development_dependency(%q<kitchen-vagrant>, ["~> 0.14"])
    else
      s.add_dependency(%q<bundler>, ["~> 1.3"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<chefspec>, ["~> 4.0"])
      s.add_dependency(%q<test-kitchen>, ["~> 1.1"])
      s.add_dependency(%q<kitchen-vagrant>, ["~> 0.14"])
    end
  else
    s.add_dependency(%q<bundler>, ["~> 1.3"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<chefspec>, ["~> 4.0"])
    s.add_dependency(%q<test-kitchen>, ["~> 1.1"])
    s.add_dependency(%q<kitchen-vagrant>, ["~> 0.14"])
  end
end
