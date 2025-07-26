require_relative 'definition'

module LLMs
  module Tool
    class Base
      include Definition

      def initialize(args)
        ## TODO convert nested hashes to symbol keys too?
        ## TODO validate args against the tool schema and raise an error if they don't match
        initialize_parameters(args.transform_keys(&:to_sym))
      end

      def run(*)
        # Default implementation is to return the parameter values as a hash
        # subclasses which need to take action should override this
        parameter_values
      end
    end
  end
end 