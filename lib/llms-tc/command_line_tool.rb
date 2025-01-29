require_relative "tool_definition"

module LLMs
  module TC
    class CommandLineTool
      include ToolDefinition

      def initialize(**args)
        initialize_parameters(args.transform_keys(&:to_sym)) ##@ TDO nested keys too
      end
    end
  end
end
