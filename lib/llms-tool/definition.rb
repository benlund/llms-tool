module LLMs
  module Tool
    module Definition
      def self.included(base)
        base.extend(ClassMethods)
      end

      class PropertyDefinitionSet
        attr_reader :property_definitions

        def initialize
          @property_definitions = {}
        end

        def parameter(name, value_type, description, required: false, default: nil, &block)
          @property_definitions[name] = PropertyDefinition.new.tap do |d|
            d.name = name
            d.description = description + (default ? " (default #{default})" : "")
            d.value_type = value_type
            d.is_required = required
            d.default = default

            if block_given?
              d.value_definition = PropertyDefinitionSet.new.tap do |nested_set|
                nested_set.instance_eval(&block)
              end
            end
          end
        end

        def to_json_schema
          {
            type: 'object',
            properties: property_definitions.transform_values(&:to_json_schema),
            required: property_definitions.select { |_, prop| prop.is_required }.keys.map(&:to_s)
          }
        end
      end

      class PropertyDefinition
        attr_accessor :name, :description, :value_type, :is_required, :value_definition, :default

        def to_json_schema
          schema = {
            type: json_type,
            description: description
          }

          if value_definition
            if value_type.to_s == 'Array'
              schema[:items] = value_definition.to_json_schema
            else
              schema.merge!(value_definition.to_json_schema)
            end
          end

          schema
        end

        private

        def json_type
          case value_type.to_s
          when 'String'  then 'string'
          when 'Integer' then 'integer'
          when 'Float'   then 'number'
          when 'Array'   then 'array'
          when 'Hash'    then 'object'
          when 'TrueClass', 'FalseClass', 'Boolean' then 'boolean'
          else 'string'
          end
        end
      end

      module ClassMethods
        def property_definition_set
          @property_definition_set ||= PropertyDefinitionSet.new
        end

        def tool_name(name = nil)
          if name.nil?
            @tool_name ||= (self.name ? self.name.split('::').last.downcase : 'class')
          else
            @tool_name = name
          end
        end

        def description(text = nil)
          if text.nil?
            @description
          else
            @description = text
          end
        end

        def parameter(name, type, description, required: false, default: nil, &block)
          property_definition_set.parameter(name, type, description, required: required, default: default, &block)
        end

        def tool_schema
          {
            name: self.tool_name,
            description: self.description,
            parameters: self.property_definition_set.to_json_schema
          }
        end
      end

      def initialize_parameters(args)
        # Validate required parameters
        missing = self.class.property_definition_set.property_definitions.select { |_, prop| prop.is_required }.keys.select { |param| !args.key?(param) }
        unless missing.empty?
          raise ArgumentError, "Missing required parameters: #{missing.join(', ')}"
        end

        # Store parameters as instance variables
        self.class.property_definition_set.property_definitions.each do |param, definition|
          value = args[param]
          value = definition.default if value.nil? && !definition.default.nil?
          instance_variable_set("@#{param}", value)

          # Define accessor method for this parameter
          self.class.class_eval do
            attr_reader param
          end
        end
      end

      def parameter_values
        {}.tap do |values|
          self.class.property_definition_set.property_definitions.each do |param, definition|
            values[param.to_s] = instance_variable_get("@#{param}")
          end
        end
      end
    end
  end
end 