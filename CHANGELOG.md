# Changelog

## Version 0.1.0 released 2025-07-26

### Added
- Initial release of LLMs::Tool gem
- Core DSL for defining LLM tools with parameters
- LLMs::Tool::Base class for creating tool implementations
- LLMs::Tool::Definition module for using just the DSL
- Support for complex nested parameters using Hash and Array types
- Parameter type mapping between Ruby and JSON Schema types:
  - String → "string"
  - Integer → "integer" 
  - Float → "number"
  - Array → "array"
  - Hash → "object"
  - Boolean → "boolean"
- Tool schema generation for LLM integration
- Example implementations:
  - Basic letter counter tool
  - Complex product page details tool with nested parameters
  - Simple module-only tool example
- Integration support with llms gem
- MIT License
