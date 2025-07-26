#!/usr/bin/env ruby

require_relative '../lib/llms-tool'

## This is a simple example of how to use the LLMs::Tool::Definition module to define a tool
## without using the LLMs::Tool::Base class

class MyTool 
  include LLMs::Tool::Definition
  tool_name :my_tool
  description "tool description"
  parameter :name, String, "parameter description"
end
  
pp MyTool.tool_schema
