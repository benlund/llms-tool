require 'spec_helper'

RSpec.describe LLMs::Tool::Base do
  let(:test_tool_class) do
    Class.new(LLMs::Tool::Base) do
      tool_name "test_base_tool"
      description "A test tool that extends Base"      
      parameter :input, String, "Input parameter", required: true
    end
  end

  describe "inheritance and inclusion" do
    it "includes the Definition module" do
      expect(LLMs::Tool::Base.included_modules).to include(LLMs::Tool::Definition)
    end

    it "has the expected class methods from Definition" do
      expect(LLMs::Tool::Base).to respond_to(:tool_name)
      expect(LLMs::Tool::Base).to respond_to(:description)
      expect(LLMs::Tool::Base).to respond_to(:parameter)
      expect(LLMs::Tool::Base).to respond_to(:tool_schema)
    end
  end

  describe "initialization" do
    it "initializes parameters correctly" do
      instance = test_tool_class.new(input: "test input")
      expect(instance.input).to eq("test input")
    end

    it "transforms string keys to symbols" do
      instance = test_tool_class.new("input" => "test input")
      expect(instance.input).to eq("test input")
    end
  end

  describe "default run method" do
    it "returns parameter values" do
      instance = test_tool_class.new(input: "test input")
      result = instance.run
      expect(result).to eq({'input' => "test input"})
    end

    it "takes any number of arguments" do
      instance = test_tool_class.new(input: "test")
      result = instance.run(1, 2, 3)
      expect(result).to eq({'input' => "test"})
    end
  end

  describe "tool schema generation" do
    it "generates correct schema for inherited tools" do
      schema = test_tool_class.tool_schema
      
      expect(schema[:name]).to eq("test_base_tool")
      expect(schema[:description]).to eq("A test tool that extends Base")
      expect(schema[:parameters][:properties][:input]).to eq({
        type: "string",
        description: "Input parameter"
      })
      expect(schema[:parameters][:required]).to eq(["input"])
    end
  end
end 