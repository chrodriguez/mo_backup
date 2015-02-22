module Mo
  module Backup

    class Component

      def self.load_chef_sugar
        extend Chef::Sugar::DSL
      end

      def self.build(components, *extras)
        (components || []).map do |component|
          component_information = prepare_information_for(component, *extras)
          build_component(component_information)
        end
      end

      def self.prepare_information_for(component, *extras)
        component
      end

      def self.build_component(component_information)
        klass = class_for(component_information)
        klass.new(component_information)
      end

      def self.lookup_module
        raise NotImplementedError
      end

      def self.class_for(component_information)
        raise "Component type is not specified." unless component_information["type"]
        class_name = component_information["type"].capitalize
        begin
          lookup_module.const_get(class_name)
        rescue NameError
          raise "Invalid component type: #{component_information["type"]}"
        end
      end

    end

  end
end
