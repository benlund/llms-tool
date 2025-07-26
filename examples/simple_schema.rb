#!/usr/bin/env ruby

require 'json'
require_relative '../lib/llms-tool'

# Creating a custom tool with simple parameters
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
tool = LetterCounter.new({word: "hello", letter: "l"})
pp tool.parameter_values
puts tool.run
