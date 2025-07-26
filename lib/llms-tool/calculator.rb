require_relative 'base'

module LLMs
  module Tool
    class Calculator < Base
      tool_name "calculator"
      description "A simple calculator that evaluates arithmetic expressions"

      parameter :expression, String, "The arithmetic expression to evaluate (e.g., '2 + 3 * 4', '(5 + 3) / 2')", required: true

      def run(*)
        unless valid_expression?(@expression)
          raise ReportableError, "Invalid expression: only numbers, operators (+, -, *, /), parentheses, and spaces are allowed"
        end
        evaluate_expression(@expression).to_s
      end

      private

      def valid_expression?(expr)
        # Only allow numbers, operators, parentheses, and spaces
        expr.match?(/^[\d\s\+\-\*\/\(\)\.]+$/)
      end

      def evaluate_expression(expr)
        # Remove all spaces
        expr = expr.gsub(/\s+/, '')
        
        # Simple recursive descent parser for basic arithmetic
        tokens = tokenize(expr)
        parse_expression(tokens)
      end

      def tokenize(expr)
        tokens = []
        i = 0
        
        while i < expr.length
          char = expr[i]
          
          case char
          when /\d/
            # Parse number (including decimals)
            num_str = ""
            while i < expr.length && (expr[i] =~ /\d/ || expr[i] == '.')
              num_str += expr[i]
              i += 1
            end
            tokens << { type: :number, value: num_str.to_f }
            next
          when '+', '-', '*', '/', '(', ')'
            tokens << { type: :operator, value: char }
          end
          
          i += 1
        end
        
        tokens
      end

      def parse_expression(tokens)
        left = parse_term(tokens)
        
        while !tokens.empty? && ['+', '-'].include?(tokens.first[:value])
          op = tokens.shift[:value]
          right = parse_term(tokens)
          
          case op
          when '+'
            left += right
          when '-'
            left -= right
          end
        end
        
        left
      end

      def parse_term(tokens)
        left = parse_factor(tokens)
        
        while !tokens.empty? && ['*', '/'].include?(tokens.first[:value])
          op = tokens.shift[:value]
          right = parse_factor(tokens)
          
          case op
          when '*'
            left *= right
          when '/'
            if right == 0
              raise ArgumentError, "Division by zero"
            end
            left /= right
          end
        end
        
        left
      end

      def parse_factor(tokens)
        if tokens.empty?
          raise ArgumentError, "Unexpected end of expression"
        end
        
        token = tokens.shift
        
        case token[:type]
        when :number
          token[:value]
        when :operator
          if token[:value] == '('
            result = parse_expression(tokens)
            
            if tokens.empty? || tokens.shift[:value] != ')'
              raise ArgumentError, "Missing closing parenthesis"
            end
            
            result
          else
            raise ArgumentError, "Unexpected operator: #{token[:value]}"
          end
        end
      end
    end
  end
end 