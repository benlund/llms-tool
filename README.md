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
# => {:name=>:my_tool, :description=>"tool description", :parameters=>{:type=>"object",
#     :properties=>{:name=>{:type=>"string", :description=>"parameter description"}}, :required=>[]}}
```

### Using Tools with an LLM

Tools can easily be called by LLMs using the [llms](https://github.com/benlund/llms) gem

```ruby
executor = LLMs::Executors.instance(
  model_name: 'claude-sonnet-4-0',
  temperature: 0.0,
  max_completion_tokens: 2048,
)

conversation = LLMs::Conversation.new.tap do |c|
  c.set_available_tools([LLMs::Tool::Calculator]) # Calculator is a simple example tool included in the llms-tool gem
  c.set_system_message("Always use the available tools to answer the question.")
  c.add_user_message("What is (two plus three) times four?")
end

response = executor.execute_conversation(conversation)
puts response.text
# => I'll calculate (two plus three) times four for you.

pp response.tool_calls
# => [#<LLMs::ConversationToolCall:0x00000001010474a8
#     @arguments={"expression"=>"(2 + 3) * 4"}, @index=0, @name="calculator",
#     @tool_call_id="toolu_01G3LVCEV1XJ7hwEhzCnrz6J", @tool_call_type="tool_use">]

tools = LLMs::Tool::Calculator.new(response.tool_calls.first.arguments)
pp tools.run
# => "20.0"
```

See `examples/llm_tool_use.rb` for a more complete example.

### Complex Parameters

You can define complex nested parameters:

```ruby
class PageDetails < LLMs::Tool::Base
  tool_name :page_details
  description "Describe structured details about a product on a web page"
  
  parameter :title, String, "The title of the product", required: true
  parameter :description, String, "The description of the product"
  parameter :dimensions, Hash, "The dimensions of the product" do
    parameter :length, Float, "The length of the product", required: true
    parameter :width, Float, "The width of the product", required: true
    parameter :height, Float, "The height of the product", required: true
  end
  parameter :prices, Array, "List of prices by quantity" do
    parameter :currency, String, "The currency of the price", required: true
    parameter :amount, Float, "The amount of the price", required: true
    parameter :order_quantity_range, String, "The quantity range of the price e.g. '1-99', '100+'", required: false
  end

  # By default run method will return the parameter values assigned by the LLM, which is what we want
end

pp PageDetails.tool_schema

# =>
# {:name=>:page_details,
#  :description=>"Describe structured details about a product on a web page",
#  :parameters=>
#   {:type=>"object",
#    :properties=>
#     {:title=>{:type=>"string", :description=>"The title of the product"},
#      :description=>{:type=>"string", :description=>"The description of the product"},
#      :dimensions=>
#       {:type=>"object",
#        :description=>"The dimensions of the product",
#        :properties=>
#         {:length=>{:type=>"number", :description=>"The length of the product"},
#          :width=>{:type=>"number", :description=>"The width of the product"},
#          :height=>{:type=>"number", :description=>"The height of the product"}},
#        :required=>["length", "width", "height"]},
#      :prices=>
#       {:type=>"array",
#        :description=>"List of prices by quantity",
#        :items=>
#         {:type=>"object",
#          :properties=>
#           {:currency=>{:type=>"string", :description=>"The currency of the price"},
#            :amount=>{:type=>"number", :description=>"The amount of the price"},
#            :order_quantity_range=>{:type=>"string", :description=>"The quantity range of the price e.g. '1-99', '100+'"}},
#          :required=>["currency", "amount"]}}},
 #   :required=>["title"]}}
```

See the `examples/` directory for runnable examples.

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
