# frozen_string_literal: true

require 'mcp'
require 'mcp/server/transports/stdio_transport'
require_relative 'kegg_tools'

module BioRuby
  module MCP
    module Server
      # BioRuby MCP Server using the official MCP Ruby SDK
      class Core
        def self.create_server
          # Create MCP server with all KEGG tools
          ::MCP::Server.new(
            name: 'bioruby-mcp-server',
            version: VERSION,
            tools: [
              KEGGPathwayTool,
              KEGGCompoundTool,
              KEGGEnzymeTool,
              KEGGSearchTool,
              KEGGPathwayFinderTool,
              KEGGOrganismTool
            ]
          )
        end

        def self.start_stdio_server
          server = create_server
          transport = ::MCP::Server::Transports::StdioTransport.new(server)
          transport.open
        end
      end
    end
  end
end