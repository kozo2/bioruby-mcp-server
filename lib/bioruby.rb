# frozen_string_literal: true

require_relative 'bioruby/mcp/server/version'
require_relative 'bioruby/mcp/server/core'
require_relative 'bioruby/mcp/server/kegg_tools'

module BioRuby
  module MCP
    module Server
      class Error < StandardError; end
    end
  end
end
