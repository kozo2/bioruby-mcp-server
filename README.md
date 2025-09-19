# bioruby-mcp-server

A Model Context Protocol (MCP) server that provides access to BioRuby KEGG functionality. This server allows AI assistants to query KEGG databases for biological pathways, compounds, enzymes, and other molecular information through the standardized MCP protocol.

Built using the official [MCP Ruby SDK](https://github.com/modelcontextprotocol/ruby-sdk).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'bioruby-mcp-server'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install bioruby-mcp-server
```

## Usage

### Starting the Server

To start the MCP server:

```bash
$ bioruby-mcp-server
```

The server will start and listen for MCP protocol messages on stdin/stdout.

### Available Tools

The server provides the following tools for interacting with KEGG databases:

#### 1. `kegg_pathway_info`
Get detailed information about a KEGG pathway.

**Parameters:**
- `pathway_id` (string): KEGG pathway ID (e.g., 'map00010', 'hsa00010')

**Example:**
```json
{
  "name": "kegg_pathway_info",
  "arguments": {
    "pathway_id": "map00010"
  }
}
```

#### 2. `kegg_compound_info`
Get detailed information about a KEGG compound.

**Parameters:**
- `compound_id` (string): KEGG compound ID (e.g., 'C00002', 'cpd:C00002')

**Example:**
```json
{
  "name": "kegg_compound_info",
  "arguments": {
    "compound_id": "C00002"
  }
}
```

#### 3. `kegg_enzyme_info`
Get detailed information about a KEGG enzyme.

**Parameters:**
- `enzyme_id` (string): KEGG enzyme ID (e.g., 'ec:1.1.1.1')

**Example:**
```json
{
  "name": "kegg_enzyme_info",
  "arguments": {
    "enzyme_id": "ec:1.1.1.1"
  }
}
```

#### 4. `kegg_search_compounds`
Search for KEGG compounds by name or formula.

**Parameters:**
- `query` (string): Search query (compound name, formula, etc.)
- `database` (string, optional): Database to search (default: 'compound')

**Example:**
```json
{
  "name": "kegg_search_compounds",
  "arguments": {
    "query": "glucose",
    "database": "compound"
  }
}
```

#### 5. `kegg_find_pathways_by_compound`
Find pathways containing a specific compound.

**Parameters:**
- `compound_id` (string): KEGG compound ID (e.g., 'C00002')

**Example:**
```json
{
  "name": "kegg_find_pathways_by_compound",
  "arguments": {
    "compound_id": "C00002"
  }
}
```

#### 6. `kegg_list_organisms`
List available organisms in KEGG.

**Parameters:**
- `filter` (string, optional): Optional filter for organism names

**Example:**
```json
{
  "name": "kegg_list_organisms",
  "arguments": {
    "filter": "human"
  }
}
```

### Integration with AI Assistants

This MCP server can be used with any AI assistant that supports the Model Context Protocol. Configure your AI assistant to connect to this server to enable KEGG database queries.

#### Example MCP Configuration

```json
{
  "mcpServers": {
    "bioruby-kegg": {
      "command": "bioruby-mcp-server",
      "args": []
    }
  }
}
```

## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Testing

Run the test suite:

```bash
$ bundle exec rake test
```

Run RuboCop for code style checking:

```bash
$ bundle exec rubocop
```

## Requirements

- Ruby 3.0 or higher
- Internet connectivity for accessing KEGG REST API

## Dependencies

- [bio](https://github.com/bioruby/bioruby) - BioRuby library for biological data processing
- [mcp](https://github.com/modelcontextprotocol/ruby-sdk) - Official MCP Ruby SDK

## Technical Implementation

This server is built using the official [MCP Ruby SDK](https://github.com/modelcontextprotocol/ruby-sdk), ensuring full compliance with the Model Context Protocol specification. Each KEGG tool is implemented as an `MCP::Tool` subclass, providing proper input schema validation and structured responses.

### Architecture

- **KEGG REST API Integration**: Direct integration with KEGG's REST API for real-time data access
- **BioRuby Parser Integration**: Uses BioRuby's KEGG parsers for proper data structure handling  
- **MCP Protocol Compliance**: Built on the official MCP Ruby SDK for standardized protocol handling
- **Tool-based Architecture**: Each KEGG operation is implemented as a separate MCP tool
- **Robust Error Handling**: Comprehensive error handling for network issues, invalid IDs, and API failures

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kozo2/bioruby-mcp-server. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/kozo2/bioruby-mcp-server/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [BSD 2-Clause License](https://opensource.org/licenses/BSD-2-Clause).

## Code of Conduct

Everyone interacting in the bioruby-mcp-server project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/kozo2/bioruby-mcp-server/blob/main/CODE_OF_CONDUCT.md).