require 'spec_helper'

RSpec.describe LLMs::Tool::Calculator do
  let(:calculator) { LLMs::Tool::Calculator.new(expression: "2 + 3") }

  describe "tool definition" do
    it "has correct tool schema" do
      schema = LLMs::Tool::Calculator.tool_schema
      
      expect(schema[:name]).to eq("calculator")
      expect(schema[:description]).to eq("A simple calculator that evaluates arithmetic expressions")
      expect(schema[:parameters][:properties][:expression]).to eq({
        type: "string",
        description: "The arithmetic expression to evaluate (e.g., '2 + 3 * 4', '(5 + 3) / 2')"
      })
      expect(schema[:parameters][:required]).to eq(["expression"])
    end
  end

  describe "basic arithmetic operations" do
    it "adds two numbers" do
      calc = LLMs::Tool::Calculator.new(expression: "2 + 3")
      result = calc.run
      ## N.B.tools results sent back to LLMs need to be strings
      ## the demo Calculator tool returns a string to demonstrate this
      expect(result).to eq('5.0')
    end

    it "subtracts two numbers" do
      calc = LLMs::Tool::Calculator.new(expression: "10 - 4")
      result = calc.run
      expect(result).to eq('6.0')
    end

    it "multiplies two numbers" do
      calc = LLMs::Tool::Calculator.new(expression: "6 * 7")
      result = calc.run
      expect(result).to eq('42.0')
    end

    it "divides two numbers" do
      calc = LLMs::Tool::Calculator.new(expression: "15 / 3")
      result = calc.run
      expect(result).to eq('5.0')
    end

    it "handles decimal numbers" do
      calc = LLMs::Tool::Calculator.new(expression: "3.5 + 2.1")
      result = calc.run
      expect(result).to eq('5.6')
    end
  end

  describe "operator precedence" do
    it "respects multiplication/division precedence over addition/subtraction" do
      calc = LLMs::Tool::Calculator.new(expression: "2 + 3 * 4")
      result = calc.run
      expect(result).to eq('14.0') # 2 + (3 * 4) = 2 + 12 = 14
    end

    it "handles multiple operations with correct precedence" do
      calc = LLMs::Tool::Calculator.new(expression: "10 - 2 * 3 + 4")
      result = calc.run
      expect(result).to eq('8.0') # 10 - (2 * 3) + 4 = 10 - 6 + 4 = 8
    end
  end

  describe "parentheses" do
    it "evaluates expressions in parentheses first" do
      calc = LLMs::Tool::Calculator.new(expression: "(2 + 3) * 4")
      result = calc.run
      expect(result).to eq('20.0') # (2 + 3) * 4 = 5 * 4 = 20
    end

    it "handles nested parentheses" do
      calc = LLMs::Tool::Calculator.new(expression: "((5 + 3) / 2) * 3")
      result = calc.run
      expect(result).to eq('12.0') # ((5 + 3) / 2) * 3 = (8 / 2) * 3 = 4 * 3 = 12
    end
  end

  describe "spaces and formatting" do
    it "ignores extra spaces" do
      calc = LLMs::Tool::Calculator.new(expression: "  2  +  3  ")
      result = calc.run
      expect(result).to eq('5.0')
    end

    it "works without spaces" do
      calc = LLMs::Tool::Calculator.new(expression: "2+3*4")
      result = calc.run
      expect(result).to eq('14.0')
    end
  end

  describe "error handling" do
    it "rejects invalid characters" do
      calc = LLMs::Tool::Calculator.new(expression: "2 + 3; echo 'hack'")
      expect { calc.run }.to raise_error(LLMs::Tool::ReportableError, /Invalid expression/)
    end

    it "handles division by zero" do
      calc = LLMs::Tool::Calculator.new(expression: "10 / 0")
      expect { calc.run }.to raise_error(ArgumentError, "Division by zero")
    end

    it "handles missing closing parenthesis" do
      calc = LLMs::Tool::Calculator.new(expression: "(2 + 3")
      expect { calc.run }.to raise_error(ArgumentError, "Missing closing parenthesis")
    end

    it "handles unexpected end of expression" do
      calc = LLMs::Tool::Calculator.new(expression: "2 +")
      expect { calc.run }.to raise_error(ArgumentError, "Unexpected end of expression")
    end

    it "handles invalid expressions gracefully" do
      calc = LLMs::Tool::Calculator.new(expression: "2 + + 3")
      expect { calc.run }.to raise_error(ArgumentError, /Unexpected operator/)
    end
  end

  describe "complex expressions" do
    it "handles complex nested expressions" do
      calc = LLMs::Tool::Calculator.new(expression: "(10 - (3 * 2)) / (4 + 1)")
      result = calc.run
      expect(result).to eq('0.8') # (10 - 6) / 5 = 4 / 5 = 0.8
    end

    it "handles multiple operations with decimals" do
      calc = LLMs::Tool::Calculator.new(expression: "3.5 * 2 + 1.5 / 3")
      result = calc.run
      expect(result).to eq('7.5') # (3.5 * 2) + (1.5 / 3) = 7 + 0.5 = 7.5
    end
  end

  describe "expression validation" do
    it "accepts valid expressions" do
      valid_expressions = [
        "2 + 3",
        "10 - 5", 
        "4 * 6",
        "15 / 3",
        "(2 + 3) * 4",
        "3.5 + 2.1",
        "2 + 3 * 4 - 1"
      ]

      valid_expressions.each do |expr|
        calc = LLMs::Tool::Calculator.new(expression: expr)
        result = calc.run
        # Calculator returns the evaluated result as a string, not the original expression
        expect(result).to be_a(String)
        expect(result.to_f).to be_a(Float)
      end
    end

    it "rejects expressions with invalid characters" do
      invalid_expressions = [
        "2 + 3;",
        "eval('2 + 3')",
        "2 + 3 && true",
        "2 + 3 || false",
        "2 + 3 > 5",
        "2 + 3 == 5"
      ]

      invalid_expressions.each do |expr|
        calc = LLMs::Tool::Calculator.new(expression: expr)
        expect { calc.run }.to raise_error(LLMs::Tool::ReportableError, /Invalid expression/)
      end
    end
  end
end 