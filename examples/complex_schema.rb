#!/usr/bin/env ruby

require 'json'
require_relative '../lib/llms-tool'

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

## Example of how to get an LLM to use the tool
## See llm_tool_use.rb for a more runnable example

# conversation = LLMs::Conversation.new.tap do |c|
#   c.set_system_message("You are a helpful assistant that can describe structured details about a product on a web page")
#   c.set_available_tools([PageDetails])
#   # html_content is a string of the HTML content on some web page you want the LLM to analyze
#   c.add_user_message("Describe the product on this page:\n" + html_content)
# end

# response = executor.execute_conversation(conversation)
# if tc = response.tool_calls.select { |tc| tc.name == 'page_details' }.first
#   pp PageDetails.new(tc.arguments).run
# else
#   conversation.add_assistant_message(response)
#   conversation.add_user_message('Please use the tool')
#   #... and then continue to execute the conversation again
# end
