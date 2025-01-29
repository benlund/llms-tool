require_relative "command_line_tool_runner"

module LLMs
  module TC
    class CurlGetRunner < CommandLineToolRunner

      attr_reader :result, :is_error ##@@ TOD move this up or out

      def run(tool)
        raise ArgumentError, "tool must be a CurlGet" unless tool.is_a?(CurlGet)
        puts "Running CurlGetRunner with tool: #{tool.inspect}"
        success = execute(['curl', '-X', 'GET', tool.url]) ##@@ TODO other options
        if success
          start_char = tool.offset || 0
          end_char = tool.limit ? start_char + tool.limit : @stdout.length
          @result = @stdout[start_char, end_char] ##todo is this char or byte???
        else
          @is_error = true
          if @raised_error
            @result = 'Internal Error: ' + @raised_error.message
          else
            @result = 'Cmd Error: ' + @stderr
          end
        end
      end

    end
  end
end
