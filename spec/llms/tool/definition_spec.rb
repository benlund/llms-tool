require 'spec_helper'

RSpec.describe LLMs::Tool::Definition do
  let(:test_class) do
    Class.new(LLMs::Tool::Base) do
      tool_name "test_tool"
      description "A test tool for testing"
      
      parameter :simple_string, String, "A simple string parameter", required: true
      parameter :optional_number, Integer, "An optional number parameter", required: false, default: 42
      parameter :boolean_flag, TrueClass, "A boolean flag", required: false, default: false
      
      def run
        # Dummy implementation
        { simple_string: @simple_string, optional_number: @optional_number, boolean_flag: @boolean_flag }
      end
    end
  end

  describe "simple tool definition" do
    it "generates correct JSON schema for simple parameters" do
      schema = test_class.tool_schema
      
      expect(schema[:name]).to eq("test_tool")
      expect(schema[:description]).to eq("A test tool for testing")
      expect(schema[:parameters][:type]).to eq("object")
      expect(schema[:parameters][:properties]).to include(
        :simple_string => {
          type: "string",
          description: "A simple string parameter"
        },
        :optional_number => {
          type: "integer",
          description: "An optional number parameter (default 42)"
        },
        :boolean_flag => {
          type: "boolean",
          description: "A boolean flag"
        }
      )
      expect(schema[:parameters][:required]).to eq(["simple_string"])
    end

    it "initializes parameters correctly" do
      instance = test_class.new(simple_string: "test", optional_number: 100)
      
      expect(instance.simple_string).to eq("test")
      expect(instance.optional_number).to eq(100)
      expect(instance.boolean_flag).to eq(false) # default value
    end

    it "uses default values when parameters are not provided" do
      instance = test_class.new(simple_string: "test")
      
      expect(instance.optional_number).to eq(42)
      expect(instance.boolean_flag).to eq(false)
    end

    it "raises error for missing required parameters" do
      expect {
        test_class.new(optional_number: 100)
      }.to raise_error(ArgumentError, /Missing required parameters/)
    end

    it "returns parameter values correctly" do
      instance = test_class.new(simple_string: "test", optional_number: 100)
      values = instance.parameter_values
      
      expect(values).to eq({
        "simple_string" => "test",
        "optional_number" => 100,
        "boolean_flag" => false
      })
    end
  end

  describe "complex tool definition with nested parameters" do
    let(:complex_class) do
      Class.new(LLMs::Tool::Base) do
        tool_name "complex_tool"
        description "A tool with complex nested parameters"
        
        parameter :user, Hash, "User information" do
          parameter :name, String, "User's full name", required: true
          parameter :email, String, "User's email address", required: true
          parameter :age, Integer, "User's age", required: false
        end
        
        parameter :settings, Array, "List of settings" do
          parameter :key, String, "Setting key", required: true
          parameter :value, String, "Setting value", required: true
        end
        
        def run
          # Dummy implementation
          { user: @user, settings: @settings }
        end
      end
    end

    it "generates correct JSON schema for nested parameters" do
      schema = complex_class.tool_schema
      
      expect(schema[:parameters][:properties][:user]).to eq({
        type: "object",
        description: "User information",
        properties: {
          :name => {
            type: "string",
            description: "User's full name"
          },
          :email => {
            type: "string",
            description: "User's email address"
          },
          :age => {
            type: "integer",
            description: "User's age"
          }
        },
        required: ["name", "email"]
      })
      
      expect(schema[:parameters][:properties][:settings]).to eq({
        type: "array",
        description: "List of settings",
        items: {
          type: "object",
          properties: {
            :key => {
              type: "string",
              description: "Setting key"
            },
            :value => {
              type: "string",
              description: "Setting value"
            }
          },
          required: ["key", "value"]
        }
      })
    end

    it "initializes complex parameters correctly" do
      instance = complex_class.new(
        user: { name: "John Doe", email: "john@example.com", age: 30 },
        settings: [
          { key: "theme", value: "dark" },
          { key: "language", value: "en" }
        ]
      )
      
      expect(instance.user[:name]).to eq("John Doe")
      expect(instance.user[:email]).to eq("john@example.com")
      expect(instance.user[:age]).to eq(30)
      expect(instance.settings).to eq([
        { key: "theme", value: "dark" },
        { key: "language", value: "en" }
      ])
    end
  end

  describe "tool name and description" do
    it "uses class name as default tool name" do
      klass = Class.new do
        include LLMs::Tool::Definition
      end
      
      # When using Class.new, the class name is nil, so it should default to 'class'
      expect(klass.tool_name).to eq("class")
    end

    it "allows custom tool name" do
      klass = Class.new do
        include LLMs::Tool::Definition
        tool_name "custom_name"
      end
      
      expect(klass.tool_name).to eq("custom_name")
    end

    it "allows setting description" do
      klass = Class.new do
        include LLMs::Tool::Definition
        description "Custom description"
      end
      
      expect(klass.description).to eq("Custom description")
    end
  end

  describe "parameter type mapping" do
    let(:type_test_class) do
      Class.new(LLMs::Tool::Base) do
        parameter :string_param, String, "String parameter"
        parameter :integer_param, Integer, "Integer parameter"
        parameter :float_param, Float, "Float parameter"
        parameter :array_param, Array, "Array parameter"
        parameter :hash_param, Hash, "Hash parameter"
        parameter :boolean_param, TrueClass, "Boolean parameter"
        parameter :unknown_param, Object, "Unknown parameter"
        
        def run
          # Dummy implementation
          {}
        end
      end
    end

    it "maps Ruby types to JSON schema types correctly" do
      schema = type_test_class.tool_schema
      properties = schema[:parameters][:properties]
      
      expect(properties[:string_param][:type]).to eq("string")
      expect(properties[:integer_param][:type]).to eq("integer")
      expect(properties[:float_param][:type]).to eq("number")
      expect(properties[:array_param][:type]).to eq("array")
      expect(properties[:hash_param][:type]).to eq("object")
      expect(properties[:boolean_param][:type]).to eq("boolean")
      expect(properties[:unknown_param][:type]).to eq("string") # default fallback
    end
  end
end 