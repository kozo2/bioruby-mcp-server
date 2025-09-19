# frozen_string_literal: true

require 'test_helper'

class TestKEGGTools < Minitest::Test
  def setup
    @tools = BioRuby::MCP::Server::KEGGTools.new
  end

  def test_available_tools
    tools = @tools.available_tools
    assert_instance_of Array, tools
    assert_operator tools.length, :>, 0

    # Check that each tool has required fields
    tools.each do |tool|
      assert tool['name']
      assert tool['description']
      assert tool['inputSchema']
    end
  end

  def test_tool_names
    tools = @tools.available_tools
    tool_names = tools.map { |t| t['name'] }

    expected_tools = %w[
      kegg_pathway_info
      kegg_compound_info
      kegg_enzyme_info
      kegg_search_compounds
      kegg_find_pathways_by_compound
      kegg_list_organisms
    ]

    expected_tools.each do |expected_tool|
      assert_includes tool_names, expected_tool
    end
  end

  def test_call_unknown_tool
    assert_raises(RuntimeError) do
      @tools.call_tool('unknown_tool', {})
    end
  end

  def test_tool_schemas_have_required_structure
    tools = @tools.available_tools

    tools.each do |tool|
      schema = tool['inputSchema']
      assert_equal 'object', schema['type']
      assert schema['properties']
    end
  end
end
