# LLMs::Tool

A Ruby gem for defining LLM tools via a simple DSL. Works well with [llms](https://github.com/benlund/llms) but can be used independently too.

See also llms-agent (coming soon) which ties this all together.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'llms-tool'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install llms-tool
```

## Usage

### Basic Tool Definition

Create a simple tool by inheriting from `LLMs::Tool::Base`:

```ruby
class LetterCounter < LLMs::Tool::Base
  tool_name :letter_counter
  description "Count the number of letters in a word"
  
  parameter :word, String, "The word to count the letters of", required: true
  parameter :letter, String, "The letter to count", required: true
  
  def run(*)
    @word.count(@letter)
  end
end

pp LetterCounter.tool_schema # Hash suitable for conversion into the JSON schema for the tool
```

Or if you just want to use the DSL you can just include the LLMs::Tool::Definition module in any class.

```ruby
class MyTool 
  include LLMs::Tool::Definition

  tool_name :my_tool
  description "tool description"
  parameter :name, String, "parameter description"
end
  
pp MyTool.tool_schema
```

### Using Tools with an LLM

Tools defined can be easily used with LLMs via the (llms) gem

```ruby
require 'llms'
# Create an instance
calculator = MyCalculator.new(expression: "2 + 3 * 4")

# Get the tool schema (useful for LLM integration)
schema = MyCalculator.tool_schema
puts schema.to_json

# Run the tool
result = calculator.run
puts result # => "14.0"
```

### Complex Parameters

You can define complex nested parameters:

```ruby
class UserProcessor < LLMs::Tool::Base
  tool_name "user_processor"
  description "Process user information"
  
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
    # Process user data
    { processed: true, user: @user, settings_count: @settings.length }
  end
end
```

## API Reference

### LLMs::Tool::Base

The base class for all tools. Includes the Definition module and provides a default constructor.

#### Methods

- `initialize(arguments)` - Initialize the tool with arguments object as supplied by an LLM
- `run(*)` - Placeholder method that subclasses should implement. By default just returns the parameter values


### LLMs::Tool::Definition

A module that provides the DSL for defining tool parameters and generating JSON schemas.

#### Class Methods

- `tool_name(name = nil)` - Set or get the tool name
- `description(text = nil)` - Set or get the tool description
- `parameter(name, type, description, required: false, default: nil, &block)` - Define a parameter
- `tool_schema` - Generate the JSON schema for the tool

#### Instance Methods

- `parameter_values` - Get a hash of all parameter values

### Parameter Types

The following Ruby types are supported and mapped to JSON schema types:

- `String` → `"string"`
- `Integer` → `"integer"`
- `Float` → `"number"`
- `Array` → `"array"`
- `Hash` → `"object"`
- `Boolean` → `"boolean"`

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/benlund/llms-tool.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
