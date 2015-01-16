module Mo
  module Backup
    module OptionsDSL

      module ClassMethods

        def option(name, type, default = nil)
          self.definition[name] = default
          define_method "sanitize_option_#{name}", &sanitize_block_for(type)
        end

        def definition
          @definition ||= {}
        end

        def component_id(id)
          @component_id = id
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

      attr_reader :id, :options

      def self.included(base)
        base.extend ClassMethods
      end

      def initialize(options)
        @id = options["id"]
        @options = sanitize(options.to_hash)
      end

      def component_id
        self.class.instance_variable_get(:@component_id) || self.class.name.split("::").last
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
  end
end
