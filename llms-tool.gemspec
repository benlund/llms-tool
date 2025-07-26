Gem::Specification.new do |spec|
  spec.name          = "llms-tool"
  spec.version       = "0.1.0"
  spec.authors       = ["Ben Lund"]
  spec.email         = ["ben@benlund.com"]

  spec.summary       = "Ruby library for creating LLM tools with a simple DSL"
  spec.description   = "LLMs::Tool provides a simple DSL for defining tools that can be serialized to the corerct JSON schema to beused with LLM systems"
  spec.homepage      = "https://github.com/benlund/llms-tool"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files         = Dir.glob("{lib}/**/*") + %w[README.md LICENSE]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rspec", "~> 3.12"
  spec.add_development_dependency "rake", "~> 13.0"
end 