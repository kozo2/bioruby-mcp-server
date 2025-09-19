# frozen_string_literal: true

require_relative 'bioruby/mcp/server/version'
require_relative 'bioruby/mcp/server/kegg_tools'
require_relative 'bioruby/mcp/server/core'

module BioRuby
  module MCP
    module Server
      class Error < StandardError; end
    end
  end
end
