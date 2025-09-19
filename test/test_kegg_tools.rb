# frozen_string_literal: true

require 'test_helper'

class TestKEGGTools < Minitest::Test
  def test_kegg_pathway_tool_structure
    tool = BioRuby::MCP::Server::KEGGPathwayTool
    assert_equal 'kegg_pathway_info', tool.tool_name
    assert_equal 'Get information about a KEGG pathway', tool.description
    assert tool.input_schema
    assert tool.input_schema.properties
    assert_includes tool.input_schema.required, :pathway_id
  end

  def test_kegg_compound_tool_structure
    tool = BioRuby::MCP::Server::KEGGCompoundTool
    assert_equal 'kegg_compound_info', tool.tool_name
    assert_equal 'Get information about a KEGG compound', tool.description
    assert tool.input_schema
    assert_includes tool.input_schema.required, :compound_id
  end

  def test_kegg_enzyme_tool_structure
    tool = BioRuby::MCP::Server::KEGGEnzymeTool
    assert_equal 'kegg_enzyme_info', tool.tool_name
    assert_equal 'Get information about a KEGG enzyme', tool.description
    assert tool.input_schema
    assert_includes tool.input_schema.required, :enzyme_id
  end

  def test_kegg_search_tool_structure
    tool = BioRuby::MCP::Server::KEGGSearchTool
    assert_equal 'kegg_search_compounds', tool.tool_name
    assert_equal 'Search for KEGG compounds by name or formula', tool.description
    assert tool.input_schema
    assert_includes tool.input_schema.required, :query
  end

  def test_kegg_pathway_finder_tool_structure
    tool = BioRuby::MCP::Server::KEGGPathwayFinderTool
    assert_equal 'kegg_find_pathways_by_compound', tool.tool_name
    assert_equal 'Find pathways containing a specific compound', tool.description
    assert tool.input_schema
    assert_includes tool.input_schema.required, :compound_id
  end

  def test_kegg_organism_tool_structure
    tool = BioRuby::MCP::Server::KEGGOrganismTool
    assert_equal 'kegg_list_organisms', tool.tool_name
    assert_equal 'List available organisms in KEGG', tool.description
    assert tool.input_schema
    # This tool has no required parameters
    assert_equal [], tool.input_schema.required
  end

  def test_tool_response_structure
    # Test that tools return proper MCP::Tool::Response objects
    tool = BioRuby::MCP::Server::KEGGPathwayTool
    
    # Mock the KEGG API call to avoid network dependency
    tool.define_singleton_method(:kegg_get_entry) do |entry_id|
      nil # Simulate not found
    end
    
    response = tool.call(pathway_id: 'invalid_id')
    assert_instance_of ::MCP::Tool::Response, response
    assert_instance_of Array, response.content
    assert_equal 'text', response.content[0][:type]
    assert_includes response.content[0][:text], 'Pathway not found'
  end

  def test_all_tools_are_tool_subclasses
    tools = [
      BioRuby::MCP::Server::KEGGPathwayTool,
      BioRuby::MCP::Server::KEGGCompoundTool,
      BioRuby::MCP::Server::KEGGEnzymeTool,
      BioRuby::MCP::Server::KEGGSearchTool,
      BioRuby::MCP::Server::KEGGPathwayFinderTool,
      BioRuby::MCP::Server::KEGGOrganismTool
    ]
    
    tools.each do |tool|
      assert tool < ::MCP::Tool, "#{tool} should inherit from MCP::Tool"
      assert_respond_to tool, :call
      assert_respond_to tool, :tool_name
      assert_respond_to tool, :description
      assert_respond_to tool, :input_schema
    end
  end
end