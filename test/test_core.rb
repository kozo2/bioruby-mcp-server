# frozen_string_literal: true

require 'test_helper'

class TestCore < Minitest::Test
  def test_server_creation
    server = BioRuby::MCP::Server::Core.create_server
    assert_instance_of ::MCP::Server, server
    assert_equal 'bioruby-mcp-server', server.name
    assert_equal BioRuby::MCP::Server::VERSION, server.version
  end

  def test_server_has_kegg_tools
    server = BioRuby::MCP::Server::Core.create_server
    tool_names = server.tools.keys
    
    expected_tools = [
      'kegg_pathway_info',
      'kegg_compound_info',
      'kegg_enzyme_info',
      'kegg_search_compounds',
      'kegg_find_pathways_by_compound',
      'kegg_list_organisms'
    ]
    
    expected_tools.each do |tool_name|
      assert_includes tool_names, tool_name
    end
  end

  def test_server_tools_count
    server = BioRuby::MCP::Server::Core.create_server
    assert_equal 6, server.tools.length
  end
end