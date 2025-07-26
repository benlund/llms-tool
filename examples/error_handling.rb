#!/usr/bin/env ruby
require_relative '../lib/llms-tool'
require 'csv'

class DatabaseQuery < LLMs::Tool::Base
  tool_name :database_query
  description "Query a database"
  parameter :sql_query, String, "The SQL query to execute", required: true

  def run(db_connection)
    begin
      # Execute the SQL query
      result = db_connection.execute_query(@sql_query)
      # results must always be a string so serialize to CSV
      CSV.generate_line(result)
    rescue DummySyntaxError => e
        # This error can be reported to the LLM so it can correct the syntax
      raise LLMs::Tool::ReportableError, "Invalid SQL syntax: #{e.message}"
    end
    # Other errors will cause the conversation to abort
  end

  private

  def execute_query(sql_query)
    # This is a placeholder for the actual query execution
    raise DummySyntaxError, "error here ----^^^^"
  end

end

# Dummy database connection class for testing
class DummyDatabaseConnection
  def execute_query(sql_query)
    raise DummySyntaxError, "error here ----^^^^"
  end
end

# Dummy error class for testing
class DummySyntaxError < StandardError
end

pp DatabaseQuery.tool_schema

tool = DatabaseQuery.new({'sql_query' => "SELECT * FROM users"})
begin
  puts "Tool result: #{tool.run(DummyDatabaseConnection.new)}"
rescue LLMs::Tool::ReportableError => e
  puts "Tool reportable error: #{e.message}"
rescue StandardError => e
  puts "Tool unreportable error: #{e.message}"
end
