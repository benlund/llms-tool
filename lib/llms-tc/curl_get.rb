require_relative "command_line_tool"

module LLMs
  module TC
    class CurlGet < CommandLineTool

      description "HTTP GET using the curl command line tool"

      parameter :url, String, "URL to request", required: true
      
      parameter :limit, Integer, "Number of bytes of the body to return", default: 5000
      parameter :offset, Integer, "Number of bytes to skip before starting to return", default: 0

      parameter :headers, Array, "Additional headers to send with the request" do
        parameter :name, String, "Name of the header", required: true
        parameter :value, String, "Value of the header", required: true
      end

    end
  end
end

