require 'open3'

module LLMs
  module TC
    class CommandLineToolRunner

      private
      
      def execute(cmd)
        begin
          @stdout, @stderr, @status = Open3.capture3(*cmd) 
          @status.success?
        rescue StandardError => e
          @raised_error = e
          nil
        end
      end
    end
  end
end
