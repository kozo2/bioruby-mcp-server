# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-09-19

### Added
- Initial release of bioruby-mcp-server
- Model Context Protocol (MCP) server implementation
- Integration with BioRuby KEGG module
- KEGG pathway information retrieval (`kegg_pathway_info`)
- KEGG compound information retrieval (`kegg_compound_info`)
- KEGG enzyme information retrieval (`kegg_enzyme_info`)
- KEGG compound search functionality (`kegg_search_compounds`)
- Pathway discovery by compound (`kegg_find_pathways_by_compound`)
- KEGG organism listing (`kegg_list_organisms`)
- Comprehensive test suite
- Command-line executable (`bioruby-mcp-server`)
- Full documentation and examples

### Technical Details
- Built on Ruby 3.0+ with BioRuby foundation
- Uses KEGG REST API for data access
- Follows MCP protocol specification 2024-11-05
- Includes proper error handling and logging
- Supports filtering and search capabilities