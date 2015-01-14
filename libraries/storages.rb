# Chef sugar library
$:.unshift *Dir[File.expand_path('../../files/default/vendor/gems/**/lib', __FILE__)]

require 'chef/sugar'

module Mo
  module Backup

    class Storage

      class << self
        include Chef::Sugar::DSL
      end

      def self.build(storages_to_use, databag)
        storages_to_use.map do |s|
          application_storage = s.dup
          main_storage = encrypted_data_bag_item(databag, s["id"])
          # Application defined values must overwrite default main storage values
          Chef::Mixin::DeepMerge.deep_merge!(application_storage, main_storage)
          build_storage(main_storage)
        end
      end

      def self.build_storage(storage_information)
        klass = class_for(storage_information)
        klass.new(storage_information)
      end

      def self.class_for(storage_information)
        raise "Storage type is not specified." unless storage_information["type"]
        class_name = storage_information["type"].capitalize
        begin
          Mo::Backup::Storages.const_get(class_name)
        rescue NameError
          raise "Invalid storage type: #{storage_information["type"]}"
        end
      end

    end


    module Storages

      module OptionsDSL

        module ClassMethods

          def option(name, type, default = nil)
            self.definition[name] = default
            define_method "sanitize_option_#{name}", &sanitize_block_for(type)
          end

          def definition
            @definition ||= {}
          end

          def storage_id(id)
            self.definition["storage_id"] = id
            define_method "sanitize_option_storage_id", &sanitize_block_for(:storage_id)
          end

          private

          def sanitize_block_for(type)
            case type
            when :symbol
              ->(value) { ":#{value}" }
            when :string
              ->(value) { "'#{value}'" }
            else
              ->(value) { value }
            end
          end

        end

        def self.included(base)
          base.extend ClassMethods
        end

      end

      class Default

        include OptionsDSL

        attr_reader :id, :options

        def initialize(options)
          @id = options["id"]
          @options = sanitize(options.to_hash)
        end

        def storage_id
          @options["storage_id"] ||= self.class.name.split("::").last
        end

        def valid_keys
          self.class.definition.keys
        end

        protected

        def sanitize(options)
          # http://stackoverflow.com/questions/17609036/how-do-i-create-the-intersection-of-two-hashes
          keys = options.keys & valid_keys
          valid_options = Hash[keys.zip(options.values_at(*keys))]
          options = default_options
          Chef::Mixin::DeepMerge.deep_merge!(valid_options, options)
          sanitize_values!(options)
          options
        end

        def default_options
          self.class.definition.reject { |k, v| v.nil? }
        end

        def sanitize_values!(options)
          options.keys.each do |key|
            options[key] = send "sanitize_option_#{key}", options[key]
          end
        end

      end


      class S3 < Default
        option "access_key_id", :string
        option "secret_access_key", :string
        option "region", :string
        option "bucket", :string
        option "path", :string
        option "keep", :number, 5
      end


      class Sftp < Default
        option "username", :string, 'user'
        option "password", :string, 'pass'
        option "ip", :string
        option "port", :number, 22
        option "path", :string, "~"
        option "keep", :number, 5
        storage_id "SFTP"
      end

    end
  end
end
