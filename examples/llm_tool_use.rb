#!/usr/bin/env ruby

require 'llms'
require_relative '../lib/llms-tool'

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
conversation.add_assistant_message(response)

puts response.text

tool_results = []

response.tool_calls.each.with_index do |tool_call, index|
  result = nil
  is_error = false

  puts "Tool call: #{tool_call.name} (#{tool_call.tool_call_id})"
  puts "Arguments: #{tool_call.arguments}"
  #t = LLMs::Tool.find(tool_call.name)
  t = LLMs::Tool::Calculator.new(tool_call.arguments)
  begin
    result = t.run
  rescue LLMs::Tool::ReportableError => e
    # The tool raised an error with a message that can be reported to the LLM
    is_error = true
    result = e.message
  rescue StandardError => e
    $stderr.puts "Error: #{e.message}"
    $stderr.puts "Tool call failed: #{tool_call.tool_call_id}"
  end

  if !result.nil?
    puts "OK: #{!is_error}"
    puts "Result: #{result}"
    tool_results << LLMs::ConversationToolResult.new(index, tool_call.tool_call_id, tool_call.tool_call_type, tool_call.name, result, is_error)
  else
    $stderr.puts "Unexpected error in tool call"
    $stderr.puts e.message
    $stderr.puts e.backtrace.join("\n")
    exit(1)
  end
end

conversation.add_user_message('Tool call results', tool_results)
response = executor.execute_conversation(conversation)
puts response.text
